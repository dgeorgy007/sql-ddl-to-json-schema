# =============================================================
# Create database
#
# https://dev.mysql.com/doc/refman/5.7/en/create-database.html

@include "./rules/index.ne"

@lexer lexer

_ -> %WS:*
__ -> %WS:+

P_CREATE_DB -> _ %K_CREATE __ %K_DATABASE (__ %K_IF ( __ %K_NOT ):? __ %K_EXISTS):? __ %S_IDENTIFIER (__ P_CREATE_DB_SPEC):? %S_EOS:?
  {% d => {
    return {
      type: 'P_CREATE_DB',
      def: {
        database: d[6]
      }
    }
  }%}

# =============================================================
# Create database spec (charset and collate)
#
# https://dev.mysql.com/doc/refman/5.7/en/charset-charsets.html
#
# TODO: do something about CHARSET and COLLATE?
# So far, it's returning null.

O_CHARSET -> ( %S_DQUOTE_STRING | %S_SQUOTE_STRING | %S_IDENTIFIER ) {% d => d[0][0] %}

O_COLLATION -> ( %S_DQUOTE_STRING | %S_SQUOTE_STRING | %S_IDENTIFIER ) {% d => d[0][0] %}

P_CREATE_DB_SPEC -> (
    ( %K_DEFAULT __ ):? %K_CHARACTER __ %K_SET _ "=":? _ O_CHARSET
      {% d => null %}
  | ( %K_DEFAULT __ ):? %K_COLLATE _ "=":? _ O_COLLATION
      {% d => null %}
  | ( %K_DEFAULT __ ):? %K_CHARACTER __ %K_SET _ "=":? _ O_CHARSET __
    ( %K_DEFAULT __ ):? %K_COLLATE _ "=":? _ O_COLLATION
      {% d => null %}
  | ( %K_DEFAULT __ ):? %K_COLLATE _ "=":? _ O_COLLATION __
    ( %K_DEFAULT __ ):? %K_CHARACTER __ %K_SET _ "=":? _ O_CHARSET
      {% d => null %}
) {% d => null %}
