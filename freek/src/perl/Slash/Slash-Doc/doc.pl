#!/usr/bin/perl -w

###############################################################################
# doc.pl - manage uploading in slash
# 
# Copyright (C) 2001 Barrapunto S.L.
# Copyright (C) 2002 Andago
# acs@barrapunto.com
# acs@andago.com
# This code is a part of Slash, and is released under the GPL.
# Copyright 1997-2001 by Open Source Development Network. See README
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#
###############################################################################

use strict;
use Image::Size;
use POSIX qw(O_RDWR O_CREAT O_EXCL tmpnam);

use Slash;
use Slash::Display;
use Slash::Utility;
use Slash::Doc;
use Slash::Projects;

sub main {
	my $user = getCurrentUser();
	my $form = getCurrentForm();
	my $slashdb = getCurrentDB();
	my $constants = getCurrentStatic();
	my $postflag = $user->{state}{post};
	my $doc = Slash::Doc->new(getCurrentVirtualUser());
	
	my $op = $form->{op};
	my($tbtitle);

	my $ops = {
	        save     => {
		    function	=> \&saveStoryUpload,
		    seclev	=> 100,
		},
		preview	 => {
		    function 	=> \&editStory,
		    seclev	=> 100,
		},
		edit	 => {
		    function 	=> \&editStory,
		    seclev	=> 100,
		},
		list	 => {
		    function	=> \&listUploads,
		    seclev	=> 100,
		},
		default	 => {
		    function    => \&listUploads,
		    seclev	=> 100,
		},
		'delete' => {
		    function 	=> \&listStories,
		    seclev	=> 10000,
		},
	};

	# doc.pl is not for regular users
	if ($user->{seclev} < 100) {
		my $rootdir = getCurrentStatic('rootdir');
		redirect("$rootdir/users.pl");
		return;
	}
	# non suadmin users can't perform suadmin ops
	unless ($ops->{$op}) {
		$op = 'default';
	}
	$op = 'list' if $user->{seclev} < $ops->{$op}{seclev};
	$op ||= 'list';

	my $db_time = $slashdb->getTime();
	my $gmt_ts = timeCalc($db_time, "%T", 0);
	my $local_ts = timeCalc($db_time, "%T");

	my $time_remark = (length $tbtitle > 10)
		? " $gmt_ts"
		: " $local_ts $user->{tzcode} = $gmt_ts GMT";
	# "backSlash" needs to be in a template or something -- pudge
	header("backSlash$time_remark$tbtitle", 'admin');

	# Admin Menu
	print "<P>&nbsp;</P>" unless $user->{seclev};

	# it'd be nice to have a legit retval
	my $retval = $ops->{$op}{function}->($form, $slashdb, $user, $constants, $doc);

	# Display who is logged in right now.
	footer();
	writeLog($user->{uid}, $op, $form->{sid});
}


##################################################################
sub listUploads {
    my $doc = Slash::Doc->new(getCurrentVirtualUser());
    my $docs = $doc->get_docs();
    slashDisplay ("list",{docs => $docs});	    
}

##################################################################
sub rmUpload {
}

##################################################################
# As it is saveStory in admin.pl but with upload support 
sub saveStoryUpload {
	my($form, $slashdb, $user, $constants, $doc) = @_;

	my $edituser = $slashdb->getUser($form->{uid});
	my $rootdir = getCurrentStatic('rootdir');

	# In the previous form of this, a section only
	# editor could assign a story to a different user
	# and bypass their own restrictions for what section
	# they could post to. -Brian
	$form->{displaystatus} ||= 1 if ($user->{section} || $edituser->{section});
	if ($user->{section} || $edituser->{section}) {
		$form->{section} = $user->{section} ? $user->{section} : $edituser->{section};
	}
	$form->{dept} =~ s/ /-/g;
	$form->{relatedtext} = getRelated(
		"$form->{title} $form->{bodytext} $form->{introtext}"
	) . otherLinks($edituser->{nickname}, $form->{tid}, $edituser->{uid});

	my $upload = $form->{query_apache}->upload;
	$form->{introtext} .= "<br><a href=\"$form->{section}/".$upload->filename."\">Adjunto</a>" if $upload;
	my $sid = $slashdb->createStory($form);
	if ($sid) {
		my $id = $slashdb->createDiscussion( {
			title	=> $form->{title},
			section	=> $form->{section},
			topic	=> $form->{tid},
			url	=> "$rootdir/article.pl?sid=$sid",
			sid	=> $sid,
			ts	=> $form->{'time'}
		});
		if ($id) {
			$slashdb->setStory($sid, { discussion => $id });
		} else {
			# Probably should be a warning sent to the browser
			# for this error, though it should be rare.
			errorLog("could not create discussion for story '$sid'");
		}
	} else {
		titlebar('100%', getData('story_creation_failed'));
		listStories(@_);
		return;
	}

	# Upload the doc
	my $section_info = $slashdb->getSection($form->{section});
	uploadDoc($doc, $user->{uid}, $form, $sid, $section_info->{id});

	my $newestthree = $slashdb->getNewestThree();
	my $newstories = {};
	for (@$newestthree) {
		my $tmpstory = $slashdb->getStory($_->[0], ['title' ]);
		$newstories->{$_->[0]}{title} = $tmpstory->{title};
	}
	my $newblock = slashDisplay('three', { stories => $newstories },
		{ Return => 1, Page => 'misc', Section => 'default' }
	);
	$slashdb->sqlUpdate('blocks', {
                        block => $newblock,
    		}, "bid='newestthree'"
	);  

	titlebar('100%', getTitle('saveStory-title'));
	listStories(@_);
}


#
#
# Exactly the same as it is in admin.pl
#
#

##################################################################
# Story Editing

sub editStory {
	my($form, $slashdb, $user, $constants, $doc) = @_;

	my($sid, $storylinks, $authorbox);

	if ($form->{op} eq 'edit') {
		$sid = $form->{sid};
	}

	my($authoredit_flag, $extracolumn_flag) = (0, 0);
	my($storyref, $story, $author, $topic, $storycontent, $storybox, $locktest,
		$sections, $topic_select, $section_select, $author_select,
		$extracolumns, $displaystatus_select, $commentstatus_select, $description);
	my $extracolref = {};
	my($fixquotes_check, $autonode_check, 
		$fastforward_check, $shortcuts_check) =
		qw(off off off off);

	for (keys %{$form}) { $storyref->{$_} = $form->{$_} }

	my $newarticle = 1 if (!$sid && !$form->{sid});

	if ($form->{title}) {
		$extracolumns = $slashdb->getSectionExtras($storyref->{section}) || [ ];
		$storyref->{writestatus} = "dirty";
		$storyref->{displaystatus} = $slashdb->getVar('defaultdisplaystatus', 'value');
		$storyref->{commentstatus} = $slashdb->getVar('defaultcommentstatus', 'value');

		$storyref->{uid} ||= $user->{uid};
		$storyref->{section} = $form->{section};

		$storyref->{writestatus} = $form->{writestatus}
			if exists $form->{writestatus};
		$storyref->{displaystatus} = $form->{displaystatus}
			if exists $form->{displaystatus};
		$storyref->{commentstatus} = $form->{commentstatus}
			if exists $form->{commentstatus};
		$storyref->{dept} =~ s/[-\s]+/-/g;
		$storyref->{dept} =~ s/^-//;
		$storyref->{dept} =~ s/-$//;

		$storyref->{introtext} = $slashdb->autoUrl(
			$form->{section}, 
			$storyref->{introtext}
		);
		$storyref->{bodytext} = $slashdb->autoUrl(
			$form->{section}, 
			$storyref->{bodytext}
		);

		$topic = $slashdb->getTopic($storyref->{tid});
		$form->{uid} ||= $user->{uid};
		$author = $slashdb->getAuthor($form->{uid});
		$sid = $form->{sid};

		if (!$form->{'time'} || $form->{fastforward}) {
			$storyref->{'time'} = $slashdb->getTime();
		} else {
			$storyref->{'time'} = $form->{'time'};
		}

		my $tmp = $user->{currentSection};
		$user->{currentSection} = $storyref->{section};

		$storycontent = dispStory($storyref, $author, $topic, 'Full');

		$user->{currentSection} = $tmp;
		$storyref->{relatedtext} = getRelated("$storyref->{title} $storyref->{bodytext} $storyref->{introtext}")
			. otherLinks($slashdb->getAuthor($storyref->{uid}, 'nickname'), $storyref->{tid}, $storyref->{uid});

		$storybox = fancybox($constants->{fancyboxwidth}, 'Related Links', $storyref->{relatedtext}, 0, 1);

	} elsif (defined $sid) { # Loading an existing SID
		my $tmp = $user->{currentSection};
		$user->{currentSection} = $slashdb->getStory($sid, 'section', 1);
		($story, $storyref, $author, $topic) = displayStory($sid, 'Full');
		$extracolumns = $slashdb->getSectionExtras($user->{currentSection}) || [ ];
		$user->{currentSection} = $tmp;
		$storybox = fancybox($constants->{fancyboxwidth}, 'Related Links', $storyref->{relatedtext}, 0, 1);

	} else { # New Story
		$extracolumns = $slashdb->getSectionExtras($storyref->{section}) || [ ];
		$storyref->{displaystatus} =	$slashdb->getVar('defaultdisplaystatus', 'value');
		$storyref->{commentstatus} =	$slashdb->getVar('defaultcommentstatus', 'value');
		$storyref->{tid} =		$slashdb->getVar('defaulttopic', 'value');
		$storyref->{section} =		$slashdb->getVar('defaultsection', 'value');

		$storyref->{'time'} = $slashdb->getTime();
		$storyref->{uid} = $user->{uid};
		$storyref->{writestatus} = "dirty";
	}

	for (@{$extracolumns}) {
		my $key = $_->[1];
		$storyref->{$key} = $form->{$key} || $storyref->{$key};
	}

	my $newestthree = $slashdb->getBlock('newestthree','block');
	my $nextthree = $slashdb->getNextThree($storyref->{time});
	my $nextstories = {};

	for (@$nextthree) {
		my $tmpstory = $slashdb->getStory($_->[0], ['title', 'uid', 'time']);
		my $author = $slashdb->getUser($tmpstory->{uid},'nickname');
		$nextstories->{$_->[0]}{title} = $tmpstory->{title};
	}

	my $nextblock = slashDisplay('three', { stories => $nextstories }, { Return => 1, Page => 'misc', Section => 'default' });
	$storylinks = $newestthree . $nextblock;

	$sections = $slashdb->getDescriptions('sections');

	$topic_select = selectTopic('tid', $storyref->{tid}, $storyref->{section}, 1);

	$section_select = selectSection('section', $storyref->{section}, $sections, 1) unless $user->{section};

	if ($user->{seclev} >= 100) {
		$authoredit_flag = 1;
		my $authors = $slashdb->getDescriptions('authors', '', 1);
		$author_select = createSelect('uid', $authors, $storyref->{uid}, 1);
	}

	$storyref->{dept} =~ s/ /-/gi;

	$locktest = lockTest($storyref->{title});

	unless ($user->{section}) {
		$description = $slashdb->getDescriptions('displaycodes');
		$displaystatus_select = createSelect('displaystatus', $description, $storyref->{displaystatus}, 1);
	}
	$description = $slashdb->getDescriptions('commentcodes');
	$commentstatus_select = createSelect('commentstatus', $description, $storyref->{commentstatus}, 1);

	$fixquotes_check	= 'on' if $form->{fixquotes};
	$autonode_check		= 'on' if $form->{autonode};
	$fastforward_check	= 'on' if $form->{fastforward};
	$shortcuts_check	= 'on' if $form->{shortcuts};

	$slashdb->setSession($user->{uid}, { lasttitle => $storyref->{title} });

	my $ispell_comments = {
		introtext =>    get_ispell_comments($storyref->{introtext}),
		bodytext =>     get_ispell_comments($storyref->{bodytext}),
	};

	$authorbox = fancybox($constants->{fancyboxwidth}, 'Story admin', $storylinks, 0, 1);
	slashDisplay('editStory', {
		storyref 		=> $storyref,
		story			=> $story,
		storycontent		=> $storycontent,
		storybox		=> $storybox,
		sid			=> $sid,
		authorbox 		=> $authorbox,
		newarticle		=> $newarticle,
		topic_select		=> $topic_select,
		section_select		=> $section_select,
		author_select		=> $author_select,
		locktest		=> $locktest,
		displaystatus_select	=> $displaystatus_select,
		commentstatus_select	=> $commentstatus_select,
		fixquotes_check		=> $fixquotes_check,
		autonode_check		=> $autonode_check,
		fastforward_check	=> $fastforward_check,
		shortcuts_check		=> $shortcuts_check,
		user			=> $user,
		authoredit_flag		=> $authoredit_flag,
		ispell_comments		=> $ispell_comments,
		extras			=> $extracolumns,
	});
	if ($form->{section}) {
	    my $section_info = $slashdb->getSection($form->{section});
	    uploadDoc($doc, $user->{uid}, $form, $sid, $section_info->{id});
	}
}

sub uploadDoc {
    my ($doc, $uid, $form, $sid, $section_id) = @_;
    my $projects = Slash::Projects->new(getCurrentVirtualUser());

    my $project_id = $projects->get_project_id ($section_id);

    my $upload = $form->{query_apache}->upload;
    if ($upload) {
	my $doc_info = {
	    uid        => $uid,
	    name       => $upload->filename,
	    size       => $upload->size,
	    project_id => $project_id,
	    sid        => $sid,
	    comments   => $form->{comments},
	};
	$doc->new_doc ($doc_info, $section_id);
    }
}

# Generated the 'Related Links' for Stories
sub getRelated {
	my($story_content) = @_;

	my $slashdb = getCurrentDB();
	my $related_links = $slashdb->getRelatedLinks();
	my $related_text;

	if ($related_links) {
		for my $key (values %$related_links) {
			if ($story_content =~ /\b$key->{keyword}\b/i) {
				my $str = qq[<LI><A HREF="$key->{link}">$key->{name}</A></LI>\n];
				$related_text .= $str unless $related_text =~ /\Q$str\E/;
			}
		}
	}

	# And slurp in all the URLs just for good measure
	while ($story_content =~ m|<A(.*?)>(.*?)</A>|sgi) {
		my($url, $label) = ($1, $2);
		$label =~ s/(\S{30})/$1 /g;
		my $str = qq[<LI><A$url>$label</A></LI>\n];
		$related_text .= $str unless $related_text =~ /\Q$str\E/
			|| $label eq "?" || $label eq "[?]";
	}

	return $related_text;
}

##################################################################
sub otherLinks {
	my($aid, $tid, $uid) = @_;

	my $slashdb = getCurrentDB();

	my $topic = $slashdb->getTopic($tid);

	return slashDisplay('otherLinks', {
		uid		=> $uid,
		aid		=> $aid,
		tid		=> $tid,
		topic		=> $topic,
	}, { Return => 1, Nocomm => 1 });
}

##################################################################
sub get_ispell_comments {
	my($text) = @_;
	$text = strip_nohtml($text);
	# don't split to scalar context, it clobbers @_
	my $n_text_words = scalar(my @junk = split /\W+/, $text);
	my $slashdb = getCurrentDB();

	my $ispell = $slashdb->getVar("ispell", "value");
	return "" if !$ispell;
	return "bad ispell var '$ispell'"
		unless $ispell eq 'ispell' or $ispell =~ /^\//;
	return "insecure ispell var '$ispell'" if $ispell =~ /\s/;
	if ($ispell ne 'ispell') {
		return "no file, not readable, or not executable '$ispell'"
			if !-e $ispell or !-f _ or !-r _ or !-x _;
	}

	# That last "1" means to ignore errors
	my $ok = $slashdb->getTemplateByName('ispellok', '', 1, '', '', 1);
	$ok = $ok ? ($ok->{template} || "") : "";
	$ok =~ s/\s+/\n/g;

	local *ISPELL;
	my $tmptext = write_to_temp_file(lc($text));
	my $tmpok = "";
	$tmpok = write_to_temp_file(lc($ok)) if $ok;
	my $tmpok_flag = "";
	$tmpok_flag = " -p $tmpok" if $tmpok;
	if (!open(ISPELL, "$ispell -a -B -S -W 3$tmpok_flag < $tmptext 2> /dev/null |")) {
		errorLog("could not pipe to $ispell from $tmptext, $!");
		return "could not pipe to $ispell from $tmptext, $!";
	}
	my %w;
	while (defined(my $line = <ISPELL>)) {
		# Grab all ispell's flagged words and put them in the hash
		$w{$1}++ if $line =~ /^[#?&]\s+(\S+)/;
	}
	close ISPELL;
	unlink $tmptext, $tmpok;

	my $comm = '';
	for my $word (sort {lc($a) cmp lc($b) or $a cmp $b} keys %w) {
		# if it's a repeated error, ignore it
		next if $w{$word} >= 2 and $w{$word} > $n_text_words*0.002;
		# a misspelling; report it
		$comm = "ispell doesn't recognize:" if !$comm;
		$comm .= " $word";
	}
	return $comm;
}

##################################################################
sub write_to_temp_file {
	my($data) = @_;
	local *TMP;
	my $tmp;
	do {
		# Note: don't mount /tmp over NFS, it's a security risk
		# See Camel3, p. 574
		$tmp = tmpnam();
	} until sysopen(TMP, $tmp, O_RDWR|O_CREAT|O_EXCL, 0600);
	print TMP $data;
	close TMP;
	$tmp;
}

##################################################################
sub getTitle {
	my($value, $hashref, $nocomm) = @_;
	$hashref ||= {};
	$hashref->{value} = $value;
	return slashDisplay('titles', $hashref,
		{ Return => 1, Nocomm => $nocomm });
}

##################################################################
sub listStories {
	my($form, $slashdb, $user, $constants, $doc) = @_;

	my($first_story, $num_stories) = ($form->{'next'} || 0, 40);
	my($count, $storylist) = $slashdb->getStoryList($first_story, $num_stories);

	my $storylistref = [];
	my($sectionflag);
	my($i, $canedit) = (0, 0);

	if ($form->{op} eq 'delete') {
		rmStory($form->{sid});
		titlebar('100%', getTitle('rmStory-title', {sid => $form->{sid}}));
	} else {
		titlebar('100%', getTitle('listStories-title'));
	}

	for (@$storylist) {
		my($hits, $comments, $sid, $title, $aid, $time_plain, $topic, $section,
			$displaystatus, $writestatus) = @$_;
		my $time = timeCalc($time_plain, '%H:%M', 0);
		my $td   = timeCalc($time_plain, '%A %B %d', 0);
		my $td2  = timeCalc($time_plain, '%m/%d', 0);

		$title = substr($title, 0, 50) . '...' if (length $title > 55);
		my $tbtitle = fixparam($title);
		if ($user->{uid} eq $aid || $user->{seclev} >= 100) {
			$canedit = 1;
		}

		$storylistref->[$i] = {
			'x'		=> $i + $first_story + 1,
			hits		=> $hits,
			comments	=> $comments,
			sid		=> $sid,
			title		=> $title,
			aid		=> $slashdb->getAuthor($aid, 'nickname'),
			'time'		=> $time,
			canedit		=> $canedit,
			topic		=> $topic,
			section		=> $section,
			td		=> $td,
			td2		=> $td2,
			writestatus	=> $writestatus,
			displaystatus	=> $displaystatus,
			tbtitle		=> $tbtitle,
		};
		$i++;
	}

	$sectionflag = 1 unless ($user->{section} || $form->{section});

	slashDisplay('list', {docs => $doc->get_docs()});
}

##################################################################
sub rmStory {
	my($sid) = @_;

	my $slashdb = getCurrentDB();
	my $constants = getCurrentStatic();

	$slashdb->deleteStory($sid);
}

createEnvironment();
main();
1;













