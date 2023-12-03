#######################################################################
# enumerate.pl
#######################################################################
# THIS IS NOT A STANDALONE PROGRAM
#
# This is a set of code snippets that shows how to enumerate the
#   Layouts and Attributes of eDirectory Objects
#
# REQUIRES:
# 0) Integrated into a Perl program that provides the appropriate
#     execution framework
# 1) Understanding of the eDirectory Schema, Objects, Attributes,
#     Values, Layouts and Syntax
#
# NOTES:
# 0) Every Object in eDirectory is associated to a Layout, defined by
#     the eDirectory schema
# 1) You can enumerate all of the Layouts in your eDirectory
#     environment by obtaining the list of Layouts from the eDirectory
#     Object
#
# KNOWN BUGS:
# 0) Some outfit called "Yumpu" has stolen an earlier version of my
#     work on this code, and is trying to make money off of it; they
#     claim to be a self-publishing website; they do not have my
#     permission to publish my work, I have no relationship with them,
#     as far as I am concerned they are thieves, and I implore anyone
#     reading this to avoid doing business with them
#
# TO DO:
# 0) Adapt to your environment
#
#######################################################################
# Change Log (Reverse Chronological Order)
# Who When______ What__________________________________________________
# dxb 2005-06-04 Initial creation (approximate date)
#######################################################################

#######################################################################
# IMPORTANT NOTE: Even for a basic modern eDirectory Tree, the outputs
#               from the three code blocks could be quite extensive.
#               For instance, just the User Object Class is defined,
#               by default, with about 200 Attributes (including the
#               ones it inherits). Modern eDirectory easily exceeds
#               a total of a thousand defined Attributes in most
#               cases, and defines over 170 Layouts. Knowing and 
#               understanding this information is crucial to being
#               able to leverage eDirectory to it's full power as a
#               business advantage.
#######################################################################

# Define local variables for accessing the list of Layouts, and
#   displaying some of their Properties:
my $LayoutList;
my $LayoutProp;

# Get the list of Layouts
$LayoutList = $eDirObj->{“Layouts”};
# Reset the pointer to the top of the list
$LayoutList->Reset();

# Display the information
print “\neDirectory defines the following Object Layouts\n”;
print “\tName\tBased On\tRemovable\n”;

# Step through the list and print selected Properties of each Layout
while ( $LayoutList->HasMoreElements() )
  {
    $LayoutProp = $LayoutList->Next();
    print “\t“, $LayoutProp->{“Name”}, “\t“, $LayoutProp->{“BasedOn”};
    if ( $LayoutProp->{“Removable”} )
      { print “\tYes\n”; }
    else
      { print “\tNo\n”; }
  }

# Each Layout specifies the Attributes of the associated Objects
# The Layout and Fields methods can be used to enumerate the structure
#   of an Object
# Declare some more local variables, retrieve the Layout for the User
#   Object, then enumerate the Fields (Attributes) in the Layout
my $Layout;
my $Fields;
my $Attribute;

# Find the Layout associated to the Object
$Layout = $Entry->{“Layout”};
# Retrieve the list of Fields in this Layout
$Fields = $Layout->{“Fields”};
# Move the list pointer to the start of the list
$Fields->Reset();
# Step through the list and print all the Fields
print “\nObject “, $Entry->{“Full Name”}, “ has the following Attributes: \n”;
# Enumerate the Object's Attributes (Fields)
while ( $Fields->HasMoreElements() )
  {
    $Attribute = $Fields->Next();
    print “\t”, $Attribute->{“Name”}, “\t”;
    if ( $Attribute->{“Optional”} )
      { print “Optional\n”; }
    else
      { print “Required\n”; }
  }

# Declare some local variables to contain information on the Syntax
# Syntax refers to the description of each Attribute; that is, is it q
#   simple data type (e.g. an integer, a BOOLEAN) or a complex data
#   type (e.g. a path, time, an ACL)
# Additionally, is the Attribute single-Valued or multi-Valued, and
#   removable or non-removable
my $TypeList;
my $TypeProp;
$TypeList = $eDirObj->{“FieldTypes”};
if ( $TypeList )
  {
    $TypeList->Reset();

    print “\neDirectory defines the following Attributes:\n”;
    print “\tName\tSyntaxType\tSyntaxName\tRemovable\n”;
    while ( $TypeList->HasMoreElements () )
      {
        $TypeProp = $TypeList->Next();
        print “\t”, $TypeProp->{“Name”}, “\t“, $TypeProp->{“SyntaxType”}, “\t“, $TypeProp->{“SyntaxName”}, “\t“);
        if ( $TypeProp->{“Removable”} )
          { print “Yes\n”; }
        else
          { print “No\n”; }
      }
  }
else
  { print “\nERROR: Could not get list of Attribute types\n”; }

# End of enumerate.pl
#####################
