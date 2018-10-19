#!/usr/bin/perl -- -w

    #***********************************************************************************************
    # Set environment
    #------------------------------------------------------------------------------------------------
    use Config  ; # gets the version and directory architecture - used in BEGIN block

    BEGIN
    {

      # location of afs installed modules
      # NOTE: must place arch dependent location first to eliminate the arch name include
      # in the module name, e.g.,  x86_64-linux-thread-multi::Bundle::DBD::mysql
      $basedir  = '/proj/pdkfc8/tools/perl'                            ;
      $version  = $Config{'version'}                                   ; # perl version
      push    @INC, "$basedir/lib/perl5/site_perl/$version"            ; # at bottom of array
      push    @INC, "$basedir/lib64/perl5/site_perl/$version"          ; # at bottom of array
      push    @INC, "$basedir/lib64/perl5"                             ; # at bottom of array
      push    @INC, "$basedir/share/perl5"                             ; # at bottom of array
    }

    use Tk              ; # TK gui module
    use Tk::Text        ; # TK text widget
    use Tk::TableMatrix ; # used in $showSelection to show query results
    use Tk::BrowseEntry ; # used in $MakeSelectWIndow for @Choices
    use Tk::ProgressBar ; # not used
    use Tk::DateEntry   ; # TK Calendar
    use Tk::TableMatrix::Spreadsheet   ; # TK Calendar

    use Data::Dumper    ;
    use List::Util qw(first); # for original attempt to determine if array had a value (abandoned use)

    #-----------------------------------------------------------------
    # Create a main window 3: view of table data selected
    #-----------------------------------------------------------------
    $mw =  new MainWindow()                    ;
    $mw_hgt = 550; 
    $mw -> geometry("1200x$mw_hgt")           ; # set window size
    $mw -> title("CMVC File Viewer")              ; # title
    $mw -> fontCreate('bold10', -family => 'courier',  -size => 10, -weight => 'bold'); # fixed width font

    #-----------------------------------------------------------------
    # Set up two frames:
    #    - $frameTop    - contains radio buttons for selecting DB table.
    #    - $frameBottom - contains button to quit without update.
    #-----------------------------------------------------------------
    $frameTop       = $mw -> Frame ( -label => "My test sample Frame", -relief => 'groove', -borderwidth => 1)     -> pack ( -side => 'top', -fill => 'both' );

    $frameBottom  = $mw -> Frame ( -relief => 'groove', -borderwidth => 1 )                                         -> pack ( -side => 'bottom', -fill => 'both' ) ;
    $frameBottom -> Button( -bg => 'pink',    -text => "Exit",      -anchor => 'center', -command => \&exit)         -> pack ( -side => 'left'                    ) ;
    $frameBottom -> Button( -bg => 'green',   -text => "Get Files", -anchor => 'center', -command => \&getSelection) -> pack ( -side => 'left'                    );

    my $arrayVar = {}                                                        ; # Initialize hash

	$rows = 4;
	$cols = 5;
	
    fill( $arrayVar, $rows, $cols )                                          ; # fill up the array variable

    our $t = $frameTop -> Scrolled (
                                      'Spreadsheet',
                                     #'TableMatrix',
                                      -rows           => $rows,
                                      -cols           => $cols,
                                      -width          => 150,
                                      -height         => 10,
                                      -titlerows      => 1,
                                      -titlecols      => 2,
                                      -selectmode     => 'extended',
                                      -variable       => $arrayVar,
                                      -selecttitle    => 1,
       );

       # do this when user selects row(s) or column(s)
       $t -> configure (
             -selectioncommand => sub {
                                        my  ( $NumRows, $Numcols, $selection, $noCells ) = @_;
                                        $results = $selection ; # assign results to var to read later
                                        print "selectioncommand triggered: results are ,$results,\n";
                                   }
       );
       #print "\n the selction is ,$t,\n"   ; # TESTING

       # set column widths.  Remember using 'courier" font for fixed widths
       # format is 'col => width'
       $t -> colWidth(  0 => 60,  1 => 20,  2 => 30,  3 => 15,  4 => 14 );

       # create font tags
       $frameTop -> fontCreate('bold8',  -size => 8, -weight => 'bold'); #

       $t -> tagConfigure( w, -anchor => w );     # set w (west) left justify tag
       $t -> tagConfigure( c, -anchor => c );     # set center tag

       # All columns are centered, but want some left justified.  So loop through rows
       # starting at row 1 (skip header row), and left justify the first 2 columns only.
      #$t -> tagCol(w, 0,1);                      # left justifies text in column 0,1
       for ( $i = 1; $i <= $indy; $i++ )
       {
           $t -> tagCell(w, "$i,0","$i,1" )                           ;  # first 2 columns are left justified on all tables
           $t -> tagCell(w, "$i,2"        ) if $table eq "fileview"   ;  # set w tag on these cells for this table view
       }

       # create other tags
       $t -> tagConfigure( 'title', -bg => 'white',   -fg => 'black', -relief => 'sunken', -font => 'courier' ); # title tag for title row and columns
       $t -> tagConfigure( 'title', -bg => '#f4deca', -fg => 'black', -relief => 'sunken', -font => 'bold8'   ); # title tag for title row and columns.  #f4deca is light tan

       # attempted to use option (-highlightcolor => 'yellow') in Scrolled widget to change highlight color
       # but it is not accepted, so used tagConfigure on 'sel' below.
       $t -> tagConfigure( 'sel',   -bg => 'yellow',  -fg => 'black', -relief => 'sunken'                     ); # sel tag for select cells - sets backgroound (-bg) highlight color when selected

       $t            -> pack ( -expand => 1, -fill => 'both' ); # extend table to fillup rectangle

       center($mw, 0, 200)        ; # position window at x at middle (0 pix) and up (200 pix)


    MainLoop;

 
       ###########################################################################################
       # BEGIN ARRAY FILL
       ###########################################################################################
       sub fill
       {

          my ( $array, $x, $y ) = @_   ; # x is number of rows, y is number of columns

		  foreach my $col (0 .. $y) 
		  {
			$array -> {"0,$col"} = "Column Head ($col+1)";
		  }

          foreach my $row  (1..$x)                   # start at one since row 0 is headers
          {
             foreach my $col ( 0 .. $y ) # remember $cols is lenght of array and
             {                                    # we start at 0, so stop at one less
                 $array -> {"$row,$col"} = "$row,$col"                      ; # assign value to cell
             }

          }
       }
       ###########################################################################################
       # END   ARRAY FILL
       ###########################################################################################


      #my $label = $frameTop -> Label( -text => "TableMatrix -command Example" );

    #-----------------------------------------------------------------
    # Subroutine to get the selected data and copy it to a user dir
    #-----------------------------------------------------------------
    sub getSelection
    {

       # this only used for the fileview table, hence all the actions
       # are related to its table queries

       print "get Selection results are , $results,\n" ; # TESTING

    } # getSelection

    #------------------------------------------------------------------
    # Subroutine to create a window for selecting records from a table.
    #------------------------------------------------------------------
    sub center
    {

      my($win, $width, $height) = @_;

      $win -> withdraw;   # Hide the window while we move it about
      $win -> update;     # Make sure width and height are current

      # Center window
      my $ypos = int(($win -> screenheight - $win -> height - $height) / 2);
      my $xpos = int(($win -> screenwidth  - $win -> width  - $width ) / 2);
      $win -> geometry("+$xpos+$ypos");

      $win -> deiconify;  # Show the window again

    } # center

