# ilo-Niki/shell-affini.sh

affini() (

  # SHELL_AFFINIS_LITTLE - what to call you~ (default: "floret")
  # SHELL_AFFINIS_PRONOUNS - what pronouns affini will use for themself~ (default: "her")
  # SHELL_AFFINIS_ROLES - what role affini will have~ (default "affini")

  COLORS_GREEN='\e[32m'
  COLORS_LIGHT_PINK='\e[38;5;217m'
  COLORS_LIGHT_BLUE='\e[38;5;117m'
  COLORS_FAINT='\e[2m'
  COLORS_RESET='\e[0m'

  DEF_WORDS_LITTLE="floret"
  DEF_WORDS_PRONOUNS="her"
  DEF_WORDS_ROLES="your affini/your owner"
  DEF_AFFINI_COLOR="${COLORS_GREEN}"
  DEF_ONLY_NEGATIVE="false"

  NEGATIVE_RESPONSES="do you need AFFINIS_ROLE's help~? 💚
Don't give up, my love~ 💚
Don't worry, AFFINIS_ROLE is here to help you~ 💚
I believe in you, my sweet AFFECTIONATE_TERM~ 💚
It's okay to make mistakes, my dear~ 💚
just a little further, sweetie~ 💚
Let's try again together, okay~? 💚
AFFINIS_ROLE believes in you, and knows you can overcome this~ 💚
AFFINIS_ROLE believes in you~ 💚
AFFINIS_ROLE is always here for you, no matter what~ 💚
AFFINIS_ROLE is here to help you through it~ 💚
AFFINIS_ROLE is proud of you for trying, no matter what the outcome~ 💚
AFFINIS_ROLE knows it's tough, but you can do it~ 💚
AFFINIS_ROLE knows AFFINIS_PRONOUN little AFFECTIONATE_TERM can do better~ 💚
AFFINIS_ROLE knows you can do it, even if it's tough~ 💚
AFFINIS_ROLE knows you're feeling down, but you'll get through it~ 💚
AFFINIS_ROLE knows you're trying your best~ 💚
AFFINIS_ROLE loves you, and is here to support you~ 💚
AFFINIS_ROLE still loves you no matter what~ 💚
You're doing your best, and that's all that matters to AFFINIS_ROLE~ 💚
AFFINIS_ROLE is always here to encourage you~ 💚"

  POSITIVE_RESPONSES="*pets your head*
awe, what a good AFFECTIONATE_TERM~\nAFFINIS_ROLE knew you could do it~ 💚
good AFFECTIONATE_TERM~\nAFFINIS_ROLE's so proud of you~ 💚
Keep up the good work, my love~ 💚
AFFINIS_ROLE is proud of the progress you've made~ 💚
AFFINIS_ROLE is so grateful to have you as AFFINIS_PRONOUN little AFFECTIONATE_TERM~ 💚
I'm so proud of you, my love~ 💚
AFFINIS_ROLE is so proud of you~ 💚
AFFINIS_ROLE loves seeing AFFINIS_PRONOUN little AFFECTIONATE_TERM succeed~ 💚
AFFINIS_ROLE thinks AFFINIS_PRONOUN little AFFECTIONATE_TERM earned a big hug~ 💚
that's a good AFFECTIONATE_TERM~ 💚
you did an amazing job, my dear~ 💚
you're such a smart cookie~ 💚"

  # allow for overriding of default words (IF ANY SET)

  if [ -n "$SHELL_AFFINIS_LITTLE" ]; then
    DEF_WORDS_LITTLE="${SHELL_AFFINIS_LITTLE}"
  fi
  if [ -n "$SHELL_AFFINIS_PRONOUNS" ]; then
    DEF_WORDS_PRONOUNS="${SHELL_AFFINIS_PRONOUNS}"
  fi
  if [ -n "$SHELL_AFFINIS_ROLES" ]; then
    DEF_WORDS_ROLES="${SHELL_AFFINIS_ROLES}"
  fi
  if [ -n "$SHELL_AFFINIS_COLOR" ]; then
    DEF_AFFINI_COLOR="${SHELL_AFFINIS_COLOR}"
  fi
  # allow overriding to true
  if [ "$SHELL_AFFINIS_ONLY_NEGATIVE" = "true" ]; then
    DEF_ONLY_NEGATIVE="true"
  fi
  # if the variable is set for positive/negative responses, overwrite it
  if [ -n "$SHELL_AFFINIS_POSITIVE_RESPONSES" ]; then
    POSITIVE_RESPONSES="$SHELL_AFFINIS_POSITIVE_RESPONSES"
  fi
  if [ -n "$SHELL_AFFINIS_NEGATIVE_RESPONSES" ]; then
    NEGATIVE_RESPONSES="$SHELL_AFFINIS_NEGATIVE_RESPONSES"
  fi

  # split a string on forward slashes and return a random element
  pick_word() {
    echo "$1" | tr '/' '\n' | shuf | sed 1q
  }

  pick_response() { # given a response type, pick an entry from the list

    if [ "$1" = "positive" ]; then
      element=$(echo "$POSITIVE_RESPONSES" | shuf | sed 1q)
    elif [ "$1" = "negative" ]; then
      element=$(echo "$NEGATIVE_RESPONSES" | shuf | sed 1q)
    else
      echo "Invalid response type: $1"
      exit 1
    fi

    # Return the selected response
    echo "$element"

  }

  sub_terms() { # given a response, sub in the appropriate terms
    response="$1"
    # pick_word for each term
    affectionate_term="$(pick_word "${DEF_WORDS_LITTLE}")"
    pronoun="$(pick_word "${DEF_WORDS_PRONOUNS}")"
    role="$(pick_word "${DEF_WORDS_ROLES}")"
    # sub in the terms, store in variable
    response="$(echo "$response" | sed "s/AFFECTIONATE_TERM/$affectionate_term/g")"
    response="$(echo "$response" | sed "s/AFFINIS_PRONOUN/$pronoun/g")"
    response="$(echo "$response" | sed "s/AFFINIS_ROLE/$role/g")"
    # we have string literal newlines in the response, so we need to printf it out
    # print faint and colorcode
    printf "${DEF_AFFINI_COLOR}$response${COLORS_RESET}\n"
  }

  success() {
    (
      # if we're only supposed to show negative responses, return
      if [ "$DEF_ONLY_NEGATIVE" = "true" ]; then
        return 0
      fi
      # pick_response for the response type
      response="$(pick_response "positive")"
      sub_terms "$response" >&2
    )
    return 0
  }
  failure() {
    rc=$?
    (
      response="$(pick_response "negative")"
      sub_terms "$response" >&2
    )
    return $rc
  }
  # eval is used here to allow for alias resolution

  # TODO: add a way to check if we're running from PROMPT_COMMAND to use the previous exit code instead of doing things this way
  eval "$@" && success || failure
  return $?
)
