#######################################################################
# find_object.pl
#######################################################################
# THIS IS NOT A STANDALONE PROGRAM
#
# This is a code snippet to demonstrate finding a specific User Object
#   without using the Search method
#
# REQUIRES:
# 0) Integration into a Perl program that provides the appropriate
#     execution framework
# 1) Understanding of the eDirectory Schema, Objects, Attributes,
#     Values, Layouts and Syntax
#
# NOTES:
# 0)
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
# As an alternative to a Search, if you know the Value of the Full Name
#   Attribute of an eDirectory Object, you can use the Item method of
#   the $Entries Object to find it

#######################################################################
# IMPORTANT NOTE: The Item method operates in the current context of
#                 the eDirectory Object, which can be changed by
#                 altering the FullName Property of the Object
#######################################################################
# Pointer to list of Objects in current context
my $ObjectList;
# Pointer to specific Object
my $Object;
# Full Name of Object I want to find
my $TargetObject = “Dave Bank”;

# Get a pointer to the list of all Objects in the current context
$ObjectList = $eDirObj->{“Entries”};

# Use the Item method to locate a specific Object
$Object = $ObjectList->Item($TargetObject);

if ( $Object )
  { print “\nFound “, $Object->{“Full Name”}, “ in context “, $eDirObj->{“FullName”}, “\n”; }
else
  { print “\nContext “, $eDirObj->{“FullName”}, “ does not contain “, $TargetObject, “\n”; }

# Alternatively, the Item method can operate against the results of
#   a successful Search (see edir_tool.pl for the Search code)
my $TargetObject = “Dave Bank”;
$Entry = $Entries->Item($TargetObject);
if ( $Entry )
  { print “\nFound “, $Entry->{“FullName”}, “ in Search results\n”; }
else
  { print “\nSearch results do not contain “, $TargetObject, “\n”; }

#######################################################################
# IMPORTANT NOTE: If the Search results encompassed a sub-Tree, then
#                 the Item method does not reveal the exact context
#                 in which TargetObject was found - only the context
#                 of the Filter object is known
#######################################################################

# End of find_object.pl
#######################
