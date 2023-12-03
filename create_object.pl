#######################################################################
# create_object.pl
#######################################################################
# THIS IS NOT A STANDALONE PROGRAM
#
# This is a code snippet to demonstrate how to create a User Object
#
# REQUIRES:
# 0) Integration into a Perl program that provides the appropriate
#     execution framework
# 1) Understanding of the eDirectory Schema, Objects, Attributes,
#     Values, Layouts and Syntax
#
# NOTES:
# 0) Since your tool can read files, it is possible to use this
#     code as the basis for a tool that can do mass Object creation;
#     for example, populating student accounts into an eDirectory
#     Tree at the start of a school year, or generating a large
#     number of accounts for temporary/seasonal workers
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
# IMPORTANT NOTE: Every Object has Mandatory Attributes; those MUST be
#                 given Values when the Object is created; other
#                 Attributes are Optional and may be omitted
#######################################################################

# This code example creates a single Object; automating mass creation
#   if left as an exercise; I also hard-code the information used
# Mandatory Attributes
my $NewObjectCN = “fjohnson”;
my $NewUserSurname = “Johnson”;

# Optional Attributes
my $NewUserFullName = “Fred Johnson”;
my $NewUserTitle = “Consultant”;
my $NewUserDescription = “Windows-to-Linux desktop migration planner”;
my $NewUserEmail = “fjohnson\@company.tld”;

my $ObjectList;
my $NewObject;



We'll build on Example 3, declaring some variables that are simply hard-coded with the data for the new User Object, and getting a pointer to the list of Objects in the current context. 
We'll create the Object with the AddElement method, then populate its Attributes with the SetFieldValue method. Finally, the Update method will commit the populated Object to eDirectory:

# I'm reusing the eDirectory Object from edit_tool.pl
# Get the Object entries for the current context
$ObjectList = $eDirObj->{“Entries”};

#######################################################################
# IMPORTANT NOTE: Objects are created in the current context, as stored
#                 in the FullName Property of the eDirectory Object.
#                 Make sure the context is properly set before creating
#                 the Object.
#######################################################################

# Create an Object of type User
$NewObject = $ObjectList->AddElement( $NewObjectCN, “User” );

#######################################################################
# IMPORTANT NOTE: The AddElement and SetFieldValue methods work on the
#                 Object in memory; however, AddElement will fail if
#                 an Object with the same CN already exists
#######################################################################

# Check success of AddElement method
if ( $NewObject )
  {
    # AddElement was successful, populate Attributes

    # Surname is a Mandatory Attribute for User Objects
    if ( $NewObject->SetFieldValue(“Surname”, $NewUserSurname ) )
      {
        # All Mandatory Attributes populated, now do optional ones
        $NewObject->SetFieldValue(“Full Name”, $NewUserFullName”);
        $NewObject->SetFieldValue(“Title”, $NewUserTitle”);
        $NewObject->SetFieldValue(“Description”, $NewUserDescription”);
        $NewObject->SetFieldValue(“Internet Email Address”, $NewUserEMail”);
      }
    else
      {
        # SetFieldValue failed for Mandatory Attribute, exit gracefully
        print LOGFILE “\nERROR setting Surname “, $NewUserSurname. “ for Object $NewObjectCN\n”;
        close (LOGFILE);
        eDirObj->logout();
        die “\nERROR setting Surname “, $NewUserSurname, “ for Object $NewObjectCN\n”;
      }
  }
else
  {
    # AddElement failed, exit gracefully
    print LOGFILE “\nERROR adding Object $NewObjectCN\n”;
    close (LOGFILE);
    eDirObj->logout();
    die “\nERROR adding Object $NewObjectCN\n”;
  }

#######################################################################
# IMPORTANT NOTE: Not until the Update method has been successfully
#                 invoked is an Object actually created in eDirectory.
#                 You can only determine success/failure of a method
#                 invocation; eDirectory error codes are not returned
#                 by the UCS APIs.
#######################################################################

# Object fully populated – commit to eDirectory
if ( $NewObject->Update() )
  { print LOGFILE “\nSuccessfully created User Object $NewObjectCN\n”; }
else
  {
    # Update failed, exit gracefully
    print LOGFILE “\nERROR committing Object $NewObjectCN to eDirectory\n”;
    close (LOGFILE);
    eDirObj->logout();
    die “\nERROR committing Object $NewObjectCN to eDirectory\n”;
  }

# End of create_object.pl
#########################
