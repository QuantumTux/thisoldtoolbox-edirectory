#######################################################################
# delete_object.pl
#######################################################################
# THIS IS NOT A STANDALONE PROGRAM
#
# This is a code snippet to demonstrate deleting an existing
#   eDirectory Object
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

#######################################################################
# IMPORTANT NOTE: Objects deletion occurs in the current context, as
#                 stored in the FullName Property of the eDirectory
#                 Object. Make sure the context is properly set before
#                 deleting the Object.
#######################################################################

# The CN of the Object to be deleted
my $TargetObject = “bjones”;

# Re-use the eDirectory Object from edir_tool.pl
# Get a list of Objects in the current context
$ObjectList = $eDirObj->{“Entries”};

print LOGFILE “\nDeleting $TargetObject\n”;

# Does the target Object exist in this context?
$Entry = $ObjectList->Item($TargetObject);

if ( $Entry )
  {
    print LOGFILE “\n\t$TargetObject is in context “, $eDirObj->{“FullName”}, “\n”;
    # Target Object found – delete it
    if ( $ObjectList->Remove($TargetObject) )
      { print LOGFILE “\tSuccessfully deleted $TargetObject\n”; }
    else
      { print LOGFILE “\nERROR attempting to delete $TargetObject\n”; }
  }
else
  # Target Object not in this context
  { print LOGFILE “\n$TargetObject does not exist in context “, $eDirObj->{“FullName”}, “\n”; }

#######################################################################
# IMPORTANT NOTE: There is no “undo” method. Regrettably, a mistaken
#                 Object deletion can only be regretted.
#######################################################################

# End of delete_object.pl
#########################
