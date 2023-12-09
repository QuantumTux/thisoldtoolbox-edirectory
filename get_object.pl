#######################################################################
# get_object.pl
#######################################################################
# THIS IS NOT A STANDALONE PROGRAM
#
# This is a code snippet to demonstrate retrieving the Attributes of
#   a specific User Object
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
# The Values contained in the Attributes of Objects may be read using
#   the GetFieldValue method
# To read an Attribute's Value(s), you must know the name of the
#   Attribute (which can be discovered by enumerating the Layout as
#   shown in enumerate.pl; or, by looking at the eDirectory Schema
#   documentation)

#######################################################################
# IMPORTANT NOTE: The name of an Attribute in eDirectory does not
#                 necessarily correspond to the name of the associated
#                 field in a tool such as ConsoleOne, nor is there
#                 always a one-to-one correspondence between an
#                 Attribute and a field in tools like ConsoleOne.
#                 For example, the workforceID Attribute is displayed
#                 by ConsoleOne in both the Employee ID and Personal ID
#                 fields of the user's Properties (User Profile tab,
#                 Business Info and Personal Info panels).
#######################################################################
my $UserCN;
my $UserName;
my @UserDescription;
my $cntrA;

# The GetFieldValue method takes two parameters: the name of the
#   Attribute, and a BOOLEAN indicating if the data is being returned
#   to a scalar (FALSE) or an array (TRUE). The default for the second
#   parameter is FALSE, and so it may be omitted for retrieving the
#   Value of a Single-Valued Attribute.
# This invocation omits the second attribute and reads the Object's
#   Common Name (which is never empty; it is a Required Attribute)
$UserCN = $Entry->GetFieldValue(“CN”);

# The method returns NULL if the Attribute's Value contained no data. It
#   is also possible for the result to be NULL if the Attribute had an
#   ACL that prevented the tool from accessing the Value, or that the
#   method failed for some other reason; however, it is not possible,
#   within the Perl code, to distinguish these conditions from an empty
#   Attribute.
# For the sake of simplicity, I assume success
print “\nUser Object: $UserCN\n”;

# I'll now demonstrate reading additional values, including a
#   Multi-Valued Attribute (MVA), which must be read into an Array
#   (even if it only has one Value)
# Here is an example of including the second parameter of
#       GetFieldValue even though it is the default
$UserName = $Entry->GetFieldValue(“Full Name”, false);
if ( $UserName )
  { print “\tFull Name: $UserName\n”; }
else
  { print “\tFull Name Attribute is blank\n”; }

# Now retrieve an MVA - in this case, the Description
# Observe that since the data is being returned to an array, the
#   second parameter of GetFieldValue must be "true"
@UserDescription = $Entry->GetFieldValue(“Description”, true);
if ( @UserDescription )
  {
    for ( $cntrA = 0 ; $cntrA < @UserDescription ; $cntrA++ )
      { print “\tDescription [$cntrA]: $UserDescription[$cntrA]\n”; }
  }
else
  { print “\tDescription Attribute is blank\n”; }

# The output should look something like this made-up example:
#
#        ...
#        User Object: tsmith
#                Full Name: Ted Smith
#                Description [0]: Promoted to Sales Manager August-15
#
#        User Object: bjones
#                Full Name: Bill Jones
#                Description Attribute is blank
#
#        User Object: jmoore
#                Full Name: Jim Moore
#                Description [0]: Retiring in September
#                Description [1]: Promoted to Sales Manager Jan-16
#
#        User Object: SysAdmin
#                Full Name Attribute is blank
#                Description Attribute is blank
#        ...
#
# End of get_object.pl
#######################
