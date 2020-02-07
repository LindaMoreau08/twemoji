# Gather the latest published emoji list from unicode  https://unicode.org/Public/emoji/latest/  (currently 12.1 with 13.0 coming soon)
#
# Files include
# emoji-data.txt	Property value for the properties listed in the Emoji Character Properties table
# emoji-variation-sequences.txt	All permissible emoji presentation sequences and text presentation sequences
# emoji-zwj-sequences.txt	ZWJ sequences used to represent emoji
# emoji-sequences.txt	Other sequences used to represent emoji
# emoji-test.txt	Test file for emoji characters and sequences


module Twemoji
  module Utils
    module Yaml

    # TODO: read emoji data and generate yaml files - crossref with twemoji list?

    end
  end
end
