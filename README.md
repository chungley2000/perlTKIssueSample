# perlTKIssueSample

I had been asked to debug a perl/TK program that had stopped working.  The develper was gone, and there was no documentation.

My skills with perl is limited and I had no experience with the TK module.  The issue is with the TK::TableMatrix.

I had stripped down a lot to make a sample.pl...  The developer uses the -selectioncommand call back to
initialize $results.  And when the "Get Files" button is clicked, he was trying to work on the $results.
However, the problem seems that this selectcommand was never called (or at least not called when the 
button "Get Files" was clicked.)  I tried reading the documentation and do some $t->get("0,0") for instance, but
that also didn't trigger the selectcommand.  I did find another solution that don't use the selectioncommand, but use
$t->curselection() when "Get Files" is clicked which seems to be what I need to do anyway.

However, it is still very interesting to me how did this work before AND also how the selectioncommand should be
triggered.

I had posted the problem on perlmonks and was asked to provide a sample code just in case that someone can take a look
and offer suggestions.  So, here it is.
