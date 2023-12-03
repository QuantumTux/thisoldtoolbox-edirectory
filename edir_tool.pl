#######################################################################
# edir_tool.pl
#######################################################################
# A semi-functional tool demonstrating practical Perl v5 code for
#   accessing and manipulating an eDirectory Directory Service using
#   Perl on a NetWare server
#
# REQUIRES:
# 0) Execution on a NetWare v6.0 or later server
# 1) The Novell-supplied Universal Component (UCS) NLMs
# 2) The Novell-supplied Perl v5.8.x interpreter
#
# NOTES:
# 0) Much of this code was published in an online AppNote or Cool
#     Solutions article, by Novell, credited to me, circa 2005/2006;
#     if you find it still online, let me know
# 1) Other resources I used to inform my work include:
#     Accessing Novell Services from Perl on NetWare (2000)
#     https://support.novell.com/techcenter/articles/ana20001007.html
#
#     How to Program to NDS eDirectory on NetWare Using Perl (2001)
#     https://support.novell.com/techcenter/articles/ana20010203.html
#
#     How to Use Perl, Python, and PHP to Access eDirectory 8.7 via LDAP (2003)
#     https://support.novell.com/techcenter/articles/dnd20030504.html
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
use warnings;
# The Universal Component Services (UCS) Perl module
require Perl2UCS;
# Declare and instantiate an eDirectory object
my $eDirObj;
$eDirObj = Perl2UCS->new(“UCX:NWDIR”) or die “\n ERROR: Unable to instantiate eDirectory object \n Exiting... \n”;
# The object was created successfully
print “\n eDirectory object successfully created”;

# To get any useful work done, the tool must login to eDirectory
# This raises a security issue; for the tool to easily login without
#   human intervention, it must have the login credentials; either
#   encoded in the tool, or read from somewhere (like a file)
# Neither of those two options is especially appealing, so consider the
#   consequences of how you design the tool
# In this example, I assume that the tool is interactive, and relies
#   on the invoker to supply valid credentials; further, I assume
#   that the login context is already known
my $Tree = ”Tree”;
my $Top_O = ”Corp”;
my $OU = ”IT”;
my $login_context = ”\\$Top_O\\$OU”;

# Note that changing the eDirectory context for the tool is merely a
#   matter of writing a new value into the FullName Property of the
#   eDirectory Object, although the context must be one into which the
#   Public Object may change context:
print “\n Setting eDirectory context to $login_context...\n”;
$eDirObj->{“FullName”} = “nds:\\\\$Tree$login_context”;

# Also, note that it is possible to force the tool to use a specific
#   server in the Tree as its Preferred Server, if you want to ensure
#   that you connect to the server holding a replica, or the Master
#   replica, of the partition with the objects you're targeting
my $ServerIP = “10.0.0.1”;
# Again, this is simply a matter of writing to the appropriate
#   Property of the eDirectory Object. While any server in the Tree
#   can execute this code, you might set the Preferred Server to
#   avoid excess eDirectory traffic
$eDirObj->{“PrefServer”} = “$ServerIP”;

# I'm now ready to solicit credentials from the invoker
my $loginID;
my $password;
print “\n\tEnter your login ID: “;
$loginID = <STDIN>;
print “\tEnter password: “;
$password = <STDIN>;
# Remove the trailing <CR> character from the variables; if you fail to
#   do this, authentication will fail
chop $loginID;
chop $password;

#######################################################################
# STOP AND CONSIDER
# At this point, I have set the eDirectory context for logging in,
#   specified a preferred server, and have gathered (hopefully) valid
#   credentials for an appropriate User object in the eDirectory Tree
#######################################################################

# The easiest way to validate the credentials is to try to login with
#   the login() method; it will return FALSE if the login fails,
#   although its not possible to tell why it failed (for example, to
#   distinguish an invalid password from a non-existent user)
print “\n\tLogging into eDirectory Tree $Tree using context $login_context as User ID $loginID...\n”;
$eDirObj->login( $loginID, $password ) or die “\n\nLogin failed, exiting...\n”;
print “\t...login successful!\n”;

#######################################################################
# IMPORTANT NOTE: Once you have successfully authenticated,
#                 using the "or die" construct is not a good
#                 idea, because you need to logout before
#                 exiting to the OS
#######################################################################

# Because NetWare doesn't have a syslog-like service, if I want to
#   log the activity of the script, I need to write to a local
#   file; note that this example assumes there is enough storage
# Technically, it is possible to write to a non-local file (on
#   another NetWare server in the same eDirectory Tree)
my $LogFile = “DATA:/Perl/scripts/logfile”;
if ( open ( LOGFILE, “>$LogFile” ) )
  { print “\n\t Logging to $LogFile...\n\n”; }
else
  {
    # Logout before exiting
    $eDirObj->logout();
    die “\n Unable to open $LogFile \n”;
  }

#######################################################################
# IMPORTANT NOTE: While it is possible for your Perl script to write
#                 its log to the SYS: Volume, I specifically recommend
#                 against doing so in practice, especially during
#                 initial development of your scripts. If your script
#                 gets stuck in a loop that includes writing to the
#                 file, then since infinite-looping scripts cannot
#                 be aborted, it is possible for your script to run
#                 the SYS: Volume out of disk space, which can crash
#                 the server and have far-reaching consequences to any
#                 eDirectory replicas it hosts. Write your files
#                 elsewhere whenever possible. If you must write to
#                 SYS:, consider applying an appropriate Directory
#                 Size Limit.
#######################################################################

# Once it has successfully authenticated, your script is free to change
#   context within the Tree, as permitted by the credentials under
#   which it is logged in. Again, changing context is simply a matter
#   of writing the new context to the FullName Property of the
#   eDirectory Object:
my $work_OU = ”Sales”;
my $work_context = ”\\$Top_O\\$work_OU”;
$eDirObj->{“FullName”} = “nds:\\\\$Tree$work_context”;

#######################################################################
# IMPORTANT NOTE: There is no return code or error check; an error will
#                 be raised when a context-sensitive method is called
#                 and it fails
#######################################################################

# It's useful to be able to search the eDirectory Tree; you can search
#   on a number of criteria, and for any eDirectory object, but here I
#   am limiting this code to just reference User Objects.
# The first step for searching is to construct a Filter Object; this
#   is done with a simple method call to the eDirectory Object
my $Filter = $eDirObj->{“Filter”};

# By default, the Filter will search in the current context of the
#   eDirectory Object (that is, the value of the FullName Property)
#   when the Filter Object was instantiated; this may be changed
#   by writing a different value into the SearchContext Property
#   of the Filter Object:
my $search_OU = “Engineering”;
my $search_context = “\\$Top_O\\$search_OU”;
$Filter->{“SearchContext”} = “nds:\\\\$Tree$search_context”;

# The next step involves defining a search Scope; it's possible to
#   search the entire eDirectory Tree with a single Filter, but I
#   recommend limiting the search via the Scope
# There are three possible Scope values, each with a pre-defined name
#   and a corresponding integer value; the names should be interpreted
#   with respect to the eDirectory Object, not the current context
#   (this is a subtle and potentially confusing distinction)
#
# Scope Name           Integer Value  Note
# SEARCH_ENTRY               0        Search the current object only
# SEARCH_SUBORDINATES        1        Search the current context, but
#                                                  not any sub-contexts
# SEARCH_SUBTREE             2        Search the current context, plus
#                                                  all OUs below it
#######################################################################
# Set Scope to current OU
$Filter->{“Scope”} = $Filter{“SEARCH_SUBORDINATES”};

# Now that a Scope is set, the next step is to formulate a Search
# A Search is made up of Expressions, and can be complex, using
#   multiple criteria with Boolean logic
# This tool uses a very simple Search that looks for User
#   Objects only
$Filter->AddExpression( $Filter->{“FTOK_EQ”}, “Object Class”, “User” );
# Once the Expression logic has been constructed, the list of
#   Expressions must be terminated
$Filter->AddExpression( $Filter->{“FTOK_END”} );

# Next, in preparation to execute the Search, initialize a pointer to
#   the list of eDirectory Objects expected to be returned:
my $Entries = $eDirObj->Reset();
# Finally, conduct the Search by applying the Filter to the
#   eDirectory Object
$Entries = $eDirObj->Search($Filter);

# The return value is a pointer to the list of matching Objects, or
#   NULL if the Filter failed to find any objects
# In the former case, the tool must reset the list pointer to the
#   start of the list (the number of Objects that matched the Search
#   criteria can also be determined)
# Initialize a counter to use if the Search is successful
my $ObjCount;
if ( $Entries )
  {
    $Entries->Reset();
    $ObjCount = $Entries->{“Count”};
    print “\nSearch successful - “, $ObjCount, “ Objects Found\n”;
  }
else
  {
    print LOGFILE “\nERROR: Search resulted in no objects...\n”;
    # It is very important to clean up!
    close(LOGFILE);
    $eDirObj->logout();
    die “\nERROR: Search resulted in no objects...\n”;
  }

# In this example, I'm not doing anything quite yet, so
#   the loop takes no action and the code exits gracefully
my $Entry;
while ( $Entries->HasMoreElements() )
  {
    # Get the next Entry
    $Entry = $Entries->Next();

    # DO SOMETHING HERE
    # See other code examples in my GitHub repo for
    #   demonstrative practical applications

    # End of while loop
  }
close(LOGFILE);
$eDirObj->logout();
die “\nEXIT: No action taken...\n”;

# End of edir_tool.pl
#####################
