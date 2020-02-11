# Stand 15.12.2019
# Länderübersicht eingebaut
# Vorschaubilder bei Mouseover in Listen
# Favoriten-Index und Flags für Wunsch/Besitz/Favorit/Gesehen
# Awards-Index
# doppelte Filme anzeigen
# Headshots eingebaut
# Pfad jetzt bei Nummer im Mouseover
# Anpassung an DB Format V48
# Flexible Anpassung von The, Ein usw.
# mit v49 Bilder für Actors, die wir hier nicht nutzen
# und nun doch mit Headshot von emdb, weil es aus imdb gezogen wird
# EMDB liegt nun in Dropbox - Public - EMDB
# HTML-Dateien und HTML greifen auf ../Covers und ../Actors zu
# neue Plattenaufteilung
# Support DB v50
# Support von Posters
# Support DB v51
# Anzahl IMDB-Bewertung
# Anpassung tabelle.csv
# Ausgabe Stand und Kommentar-Hinweis
# Support DB v52
# Support DB v53
# Support DB v54
# neues Konzept bei Gruppen + div. neue Ländercodes
# mehr Länder in der Liste
# Support DB v55
# IMDB Metacritics
# Drehbuch und Soundtrack bei Filmausgabe
# Bugfix csv
# Support DB v56
# Komplett neuer DB Aufbau mit DB v57
# jetzt mit IMDB LInk auf Darsteller
# Support DB v58 mit IMDB TOP250
# doppelte Filme mit Spalte Jahr
# DB v60 mit Anpassung bei Metascore-Format
# DB v61
# EMDB-Gruppen als Festplattenablageort eingebaut

use Data::Dumper;
use Encode;
use File::Basename;

sub conv_line {
	my $val = $_[0];
	chop($val);
	chop($val);
	$val = Encode::encode("utf-8", $val);
	return $val;
}
sub txt2url {
	my $val = $_[0];
	$val = lc($val);
	$val =~ s/\.//g;
	$val =~ s/ /-/g;
	$val =~ s/ä/ae/g;
	$val =~ s/ö/oe/g;
	$val =~ s/ü/ue/g;
	$val =~ s/ß/ss/g;
	$val =~ s/é//g;
	$val =~ s/è//g;
	$val =~ s/á//g;
	$val =~ s/à//g;
	$val =~ s/ñ//g;
	$val =~ s/\&/+/g;
	$val =~ s/\'//g;
	$val =~ s/\\/ /g;
	return $val;
}
sub tvdat {
	my $tv = $_[0];
	my $tvmnr = $_[1];
	open (TVF, "<:encoding(ucs-2le)", "../TVSeries/$tv/$tv.dat") || return;
	
	$tvnr = 1;
	$tvline = <TVF>;
	$tvline = conv_line($tvline);
	if (!($tvline =~ m/\[Version0[234]\]/)) {
		print "Falsches TV DB-Format TVSeries/$tv/$tv.dat";
		return;
	}
	$tvline = <TVF>;
	$tvtitle = conv_line($tvline);
	$tvline = <TVF>;
	$tvjahre = conv_line($tvline);
	$tvline = <TVF>;
	$tvdesc = conv_line($tvline);
	$tvline = <TVF>;
	$tvmulti = conv_line($tvline);
	$tvline = <TVF>;
	$tvmulti = conv_line($tvline);
	$tvline = <TVF>;
	$tvmulti = conv_line($tvline);
	open (TVO, ">TVDat/$tv.html") || return;
	print TVO "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1>\n";
	print TVO "<h1><small><small>#$tvmnr</small></small> <a href='../Movies/$tvmnr.html'>$tvtitle</a> <small>(Serien-&Uuml;bersicht)</small> <a href='../Genres/tv-serie.html'><img src='../tv.png' border='0' title='TV-Serien'></a></h1>\n<p>Produziert: $tvjahre</p>\n";
	if (-s "../TVSeries/$tv/banner.jpg") {
		print TVO "<img src='../../TVSeries/$tv/banner.jpg' border='0' class='cover' title='$tvtitle'><br clear='all'>\n";
	}
	print TVO "<p>$tvdesc</p>\n";
	while ($tvline = <TVF>) {
		$tvline = conv_line($tvline);
		if ($tvline =~ m/^[0-9]*$/ || $tvline =~ m/^N|Y$/ || $tvline =~ m/^\[TheEnd\]$/) {
			$tvnr++;
			next;
		}
		if ($tvline =~ m/(.*)\|.*/) {
			# episoden-titel
			print TVO "<h1>$tvepisode: $1</h1>\n";
			$tvnr++;
			next;
		}
		if ($tvline =~ m/\[(.*)\]/) {
			# episoden-nr oder season-nr
			$tvepisode = $1;
					
			$tvurl = txt2url($1);
			#print TVO "<i>../TVSeries/$tv/$tvurl.jpg</i>\n";
			if (-s "../TVSeries/$tv/$tvurl.jpg") {
				print TVO "<img src='../../TVSeries/$tv/$tvurl.jpg' border='0' class='cover' title='$tvepisode'>\n";
				print TVO "<h1>$tvepisode</h1>\n";
			} elsif ($tvepisode =~ m/season/i ) {
				print TVO "<h1>$tvepisode</h1>\n";
			}
			
			$tvnr++;
			next;
		}
		print TVO "<p>$tvline</p>\n";
		$tvnr++;
	}
	
	print TVO "</body></html>\n";
	close (TVF);
	close (TVO);
	#print "GOTCHA $tv\n";
	return;
}

%sprachcode = (
	"E" => "Englisch",
	"G" => "Deutsch",
	"J" => "Japanisch",
	"K" => "Koreanisch",
	"F" => "Französisch"
);
%landcode = (
	"albania" => "Albanien",
	"algeria" => "Algerien",
	"argentina" => "Argentinien",
	"armenia" => "Armenien",
	"aruba" => "Aruba",
	"australia" => "Australien",
	"austria" => "Österreich",
	"bahamas" => "Bahamas",
	"belarus" => "Balearen",
	"belgium" => "Belgien",
	"brazil" => "Brasilien",
	"bulgaria" => "Bulgarien",
	"cambodia" => "Kambodscha",
	"canada" => "Kanada",
	"chile" => "Chile",
	"china" => "China",
	"colombia" => "Kolumbien",
	"croatia" => "Kroatien",
	"cuba" => "Kuba",
	"cyprus" => "Zypern",
	"czechoslovakia" => "Tschechoslowakei ",
	"czech-republic" => "Tschechische Republik",
	"denmark" => "Dänemark",
	"dominican-republic" => "Dominikanische Republik",
	"east-germany" => "Ost-Deutschland",
	"egypt" => "Ägypten",
	"estonia" => "Estonien",
	"finland" => "Finnland",
	"france" => "Frankreich",
	"georgia" => "Georgien",
	"germany" => "Deutschland",
	"greece" => "Griechenland",
	"hong-kong" => "Hong-Kong",
	"hungary" => "Ungarn",
	"iceland" => "Island",
	"india" => "Indien",
	"indonesia" => "Indonesien",
	"iran" => "Iran",
	"ireland" => "Irland",
	"israel" => "Israel",
	"italy" => "Italien",
	"japan" => "Japan",
	"kazakhstan" => "Kasachstan",
	"kenya" => "Kenia",
	"korea" => "Korea",
	"kosovo" => "Kosovo",
	"kyrgyzstan" => "Kirgisistan",
	"latvia" => "Lettland",
	"lebanon" => "Libanon",
	"lithuania" => "Lithauen",
	"luxembourg" => "Luxemburg",
	"malaysia" => "Malaysia",
	"malta" => "Malta",
	"mauritania" => "Mauretanien",
	"mexico" => "Mexiko",
	"netherlands" => "Niederlande",
	"new-zealand" => "Neuseeland",
	"nigeria" => "Nigeria",
	"norway" => "Norwegen",
	"panama" => "Panama",
	"paraguay" => "Paraguay",
	"peru" => "Peru",
	"philippines" => "Philippinen",
	"poland" => "Polen",
	"portugal" => "Portugal",
	"puerto-rico" => "Puerto-Rico",
	"republic-of-macedonia" => "Mazedonien",
	"romania" => "Rumänien",
	"russia" => "Russland",
	"saudi-arabia" => "Saudi-Arabien",
	"serbia" => "Serbien",
	"singapore" => "Singapur",
	"slovakia" => "Slowakei",
	"somalia" => "Somalia",
	"south-africa" => "Süd-Afrika",
	"south-korea" => "Süd-Korea",
	"soviet-union" => "Soviet-Union",
	"spain" => "Spanien",
	"sweden" => "Schweden",
	"switzerland" => "Schweiz",
	"taiwan" => "Taiwan",
	"thailand" => "Thailand",
	"turkey" => "Türkei",
	"uk" => "England",
	"ukraine" => "Ukraine",
	"united-arab-emirates" => "Vereinigte Arabische Emirate",
	"usa" => "USA",
	"venezuela" => "Venezuela",
	"vietnam" => "Vietnam",
	"west-germany" => "West-Deutschland",
	"yugoslavia" => "Jugoslawien"
);
%toncode = (
	"c" => "DD5.1", 
	"f" => "DD2.0",
	"x" => "DD1.0",
	"d" => "DTS",
	"u" => "DTS-HD",
	"b" => "MPEG2",
	"s" => "AAC5.1",
	"r" => "AAC2.0"
);
%genreclear = ( 
	"A" => "Action",
	"T" => "Thriller",
	"H" => "Horror",
	"D" => "Drama",
	"S" => "Sci-Fi",
	"M" => "Musik",
	"K" => "Komödie",
	"V" => "Abenteuer",
	"O" => "Krieg",
	"F" => "Fantasy",
	"!" => "Krimi",
	"C" => "Animation/Trick",
	"I" => "Familie",
	"U" => "Dokumentation",
	"G" => "Geschichte",
	"R" => "Liebe",
	"Y" => "Mystery",
	"N" => "Kabarett",
	"P" => "Sport",
	"W" => "Western", 
	"@" => "Biographie",
	" " => "Erotik",
	"s" => "Kurzfilm",
	" " => "Film-Noir",
	"m" => "Musical",
	" " => "Reality-TV",
	" " => "Game-Show",
	" " => "Talk-Show",
	"#" => "TV-Serie",
	"1" => "Weihnachten"
);
%genrefile = ( 
	"A" => "action",
	"T" => "thriller",
	"H" => "horror",
	"D" => "drama",
	"S" => "scifi",
	"M" => "musik",
	"K" => "komoedie",
	"V" => "abenteuer",
	"O" => "krieg",
	"F" => "fantasy",
	"!" => "krimi",
	"C" => "aimation-trick",
	"I" => "familie",
	"U" => "dokumentation",
	"G" => "geschichte",
	"R" => "liebe",
	"Y" => "mystery",
	"N" => "kabarett",
	"P" => "sport",
	"W" => "western", 
	"@" => "biographie",
	" " => "erotik",
	"s" => "kurzfilm",
	" " => "film-noir",
	"m" => "musical",
	" " => "reality-tv",
	" " => "game-show",
	" " => "talk-show",
	"#" => "tv-serie",
	"1" => "weihnachten"
);
%zeitName = (
	"000" => "nicht angegeben",
	"060" => "kleiner 1 Stunde",
	"090" => "1 bis 1 &frac12; Stunden",
	"120" => "1 &frac12; bis 2 Stunden",
	"150" => "2 bis 2 &frac12; Stunden",
	"180" => "2 &frac12; bis 3 Stunden",
	"181" => "&uuml;ber 3 Stunden"
);
%beliebtheitName = (
	"000000" => "keine Bewertungen",
	"000100" => "1-100 Bewertungen",
	"001000" => "100-1.000 Bewertungen",
	"005000" => "1.000-5.000 Bewertungen",
	"010000" => "5.000-10.000 Bewertungen",
	"025000" => "10.000-25.000 Bewertungen",
	"050000" => "25.000-50.000 Bewertungen",
	"075000" => "50.000-75.000 Bewertungen",
	"100000" => "75.000-100.000 Bewertungen",
	"250000" => "100.000-250.000 Bewertungen",
	"250001" => "mehr als 250.000 Bewertungen",
);
# main
$MINACTORS = 5;
$MINDIRECTORS = 2;
@GROUPS = ();
@ACTORS = ();
@ACTORSHEADSHOT = ();
@ACTORSID = ();
@DIRECTORS = ();
@DIRECTORSHEADSHOT = ();
@WRITERS = ();
@SOUNDTRACKWRITERS = ();
%FILME = {};
%indexGenre = {};
%indexActors = {};
%indexDirectors = {};
%indexJahr = {};
%index3D = {};
%indexFSK = {};
%indexZeit = {};
%indexIMDB = {};
%indexMetascore = {};
%indexGruppe = {};
%indexFavorit = {};
%indexAward = {};
%indexTopRated = {};
%indexImdbCount = {};
%indexLand = {};
%indexBeliebtheit = {};
mkdir("TVDat", "755");

open (F, "<:encoding(ucs-2le)", "../emdb.dat") || die "Can't open emdb.dat - $!\n";
$nr = 1;
$ingroups = 0;
$inmovies = 0;
$inactors = 0;
$indirectors = 0;
$inwriters = 0;
$firstinwriters = 1;
$insoundtrackwriters = 0;

# Einlesen der Datenbank und speichern in Arrays
$| = 1;
print "Einlesen DB: ";
while ($line = <F>) {
	$line = conv_line($line);
	
	if ($nr == 2 && !($line =~ m/"version": "61"/)) {
		print "Falsches DB-Format";
		exit;
	}
	if ($line =~ m/"groups":/) {
		$ingroups = 1;
		print "Gruppen... ";
		next;
	} elsif ($line =~ m/"movies":/) {
		$inmovies = 1;
		$ingroups = 0;
		$mnr = 1;
		print "Movies... ";
		next;
	} elsif($line =~ m/"actors":/) {
		$inactors = 1;
		$inmovies = 0;
		print "Actors... ";
		next;
	} elsif($line =~ m/"directors":/) {
		$indirectors = 1;
		$inactors = 0;
		print "Directors... ";
		next;
	} elsif($line =~ m/"writers":/) {
		print "Writers...";
		if ($firstinwriters) {
			# seltsam - es gibt 2x Abschnitt Writers, zuerst nur < 10 Namen ...
			$indirectors = 0;
			$firstinwriters = 0;
			$inwriters = 1;
			next;
		} else {
			$inwriters = 1;
			$indirectors = 0;
		}
		
	} elsif($line =~ m/"composers":/) {
		$insoundtrackwriters = 1;
		$inwriters = 0;
		print "SoundtrackWriters...\n";
		next;
	} elsif($line =~ m/^\s*\]$/) {
		$inwriters = 0;
		$insoundtrackwriters = 0;
		next;
	}
	if ($ingroups) {
		if ($line =~ m/^\s*"name": "(.*)",$/) {
			$gr = "$1";
			push(@GROUPS, $gr);
		}
		
	}
	if ($inactors) {
		# Daniel Craig0185819
		# NEU        "name": "Daniel Craig",
        # "id": "0185819"
        # }, {
		if ($line =~ m/^\s*"name": "(.*)",$/) {
			$name = "$1";
		}
		$line = <F>;
		$line = conv_line($line);
		if ($line =~ m/^\s*"id": "(.*)"$/) {
			$id = $1;
		} else {
			$id = 0;
		}
		#print "$name-$id--";
		push(@ACTORS, $name);
		push(@ACTORSID, $id);
		if (-e "../Actors/$id.jpg") {
			push(@ACTORSHEADSHOT, "../Actors/$id.jpg");
		} elsif (-e "../Headshots/$name.jpg") {
			push(@ACTORSHEADSHOT, "../Headshots/$name.jpg");
		} else {
			push(@ACTORSHEADSHOT, "");
		}
		# Abschlusszeile weglesen
		if ($id) {
			$line = <F>;
			$line = conv_line($line);
			if ($line =~ m/^\s*}$/) {
				$line = <F>;
			}
		}
	}
	if ($indirectors) {
		# {"name": "Joe Johnston"},
		if ($line =~ m/^\s*{"name":\s*"(.*)"},$/) {
			$line = $1;
		}
		push(@DIRECTORS, $line);
		if (-e "../Headshots/$line.jpg") {
			push(@DIRECTORSHEADSHOT, "$line.jpg");
		} else {
			push(@DIRECTORSHEADSHOT, "");
		}
	}
	if ($inwriters) {
		#  {"name": "Brett Haley"},
		if ($line =~ m/^\s*{"name":\s*"(.*)"},$/) {
			$line = "$1";
		}
		push(@WRITERS, $line);
	}
	if ($insoundtrackwriters) {
		#{"name": "Gösta Sundqvist"},
		if ($line =~ m/^\s*{"name":\s*"(.*)"},$/) {
			$line = $1;
		}
		push(@SOUNDTRACKWRITERS, $line);
	}
	if ($inmovies) {
		$film = {};
		$film->{nr} = $mnr;
		#$line = conv_line($line);
		# Avatar - Aufbruch nach PandoraAvatar20th Century Fox-1
		# NEU "title": "#99Focus Features-1",
		# "title": "2 Tage New YorkSenator Film18,13,0,1,10-1",
		if ($line =~ m/^\s*"title":\s*"(.*)",$/s) {
			$line = $1
		}
		($film->{titel}, $film->{otitel}, $film->{studio}, $film->{groups}, $unknown2) = split(//, $line);
		$film->{groupslist} = "";
		foreach $gr (split(/,/, $film->{groups})) {
			$film->{groupslist} .= '[' . $GROUPS[$gr] . '],';
		}
		$film->{groupslist} =~ s+,$++;
		if ($film->{otitel} =~ m/#([A-Z])(.*)/) {
			if ($1 eq "E") {
				$film->{otitel} = "$2 (Englischer Titel)";
			} elsif ($1 eq "O") {
				$film->{otitel} = "$2 (Originaltitel)";
			}
		}
		$film->{ptitel} = $film->{titel};
		if ($film->{titel} =~ m/^(The|A|Der|Die|Das|Eine|Ein) (.*)/) {
			$film->{titel} = "$2, $1";
		}
		if ($film->{titel} =~ m/^(.*), (The|A|Der|Die|Das|Eine|Ein)$/) {
			$film->{ptitel} = "$2 $1";
		}
		$line = <F>;
		$line = conv_line($line);
		# 200961  162USA661920×1080        X:\2009,1\Avatar.mkv-291100311  5
		# 2008619995 USA04720x576 (PAL DVD)PATH                -101100119416137,57581550,1551
		# NEU "year": "20095979USA651920×1040X:\HD-Trick\#9 (2009, FSK12, 1920x1040).mkv-20110017,6144314",
		if ($line =~ m/^\s*"year":\s*"(.*)",$/s) {
			$line = $1;
		}
		($film->{jahr}, $dir, $film->{dauer}, $film->{land}, $u, $u, $film->{resolution}, $film->{pfad}, $u, $film->{flags}, $u, $u, $u, $u, $img, $writers, $soundtrackwriters) = split(//, $line);
		if (hex($film->{flags}) & 0b0001) {
			$film->{flag_gesehen} = 1;
		}
		if (hex($film->{flags}) & 0b0010) {
			$film->{flag_wunschliste} = 1;
		}
		if (hex($film->{flags}) & 0b0100) {
			$film->{flag_besitz} = 1;
		}
		if (hex($film->{flags}) & 0b1000) {
			$film->{flag_favorit} = 1;
			$indexFavorit{$mnr} = $mnr;
		}
		$indexLand{txt2url($film->{land})}{$mnr} = $mnr;
		$film->{gruppe} = dirname(($film->{pfad}));
		$film->{gruppe} =~ s/^[a-z]:\\//i;
		# Dokumentationen und Collections nur eine Unterebene, deshalb hier prüfen, wo \ im Pfad noch da
		if ($film->{gruppe} =~ m/^(Dokumentationen\\.*?)\\.*$/i) {
			$film->{gruppe} = $1;
		}
		if ($film->{gruppe} =~ m/^(.*Collections\\.*?)\\.*$/i) {
			$film->{gruppe} = $1;
		}
		# NEU ohne Unterbereiche
		if ($film->{gruppe} =~ m/^(NEU)\\.*$/i) {
			$film->{gruppe} = $1;
		}
		# Serien zusammenfassen
		if ($film->{gruppe} =~ m/^(.*[ -]serien).*$/i) {
			$film->{gruppe} = $1;
		}
		# Plattenbezeichner herausnehmen, falls diese versehentlich noch drin
		$film->{gruppe} =~ s/<sc>//i;
		$film->{gruppe} =~ s/<scb>//i;
			
		$indexGruppe{$film->{gruppe}}{$mnr} = $mnr;
		if (!$indexGruppe{$film->{gruppe}}{'dauer'}) {
			$indexGruppe{$film->{gruppe}}{'dauer'} = 0;
		}
		
		if (!$indexGruppe{$film->{gruppe}}{'count'}) {
			$indexGruppe{$film->{gruppe}}{'count'} = 0;
		}
		if (!$indexGruppe{$film->{gruppe}}{'mb'}) {
			$indexGruppe{$film->{gruppe}}{'mb'} = 0;
		}
		$indexGruppe{$film->{gruppe}}{'dauer'} += $film->{dauer};
		$indexGruppe{$film->{gruppe}}{'count'} ++;
		
		
		if (int $film->{dauer} == 0) {
			$film->{zeit} = "000";
			$film->{dauer} = "undefiniert";
		} elsif (int $film->{dauer} < 60) {
			$film->{zeit} = "060";
		} elsif (int $film->{dauer} < 90) {
			$film->{zeit} = "090";
		} elsif (int $film->{dauer} < 120) {
			$film->{zeit} = "120";
		} elsif (int $film->{dauer} < 150) {
			$film->{zeit} = "150";
		} elsif (int $film->{dauer} < 180) {
			$film->{zeit} = "180";
		} else {
			$film->{zeit} = "181";
		}
		$indexZeit{$film->{zeit}}{$mnr} = $mnr;
		
		if ($film->{resolution} =~ m/^([0-9]*)/) {
			if ($1 > 1400) {
				$film->{reso} = "1080p";
			} elsif ($1 > 950) {
				$film->{reso} = "720p";
			} else {
				$film->{reso} = "SD";
			}
		}
		$indexJahr{$film->{jahr}}{$mnr} = $mnr;
		$film->{cover} = sprintf("%06d.jpg", $img);
		@{$film->{directors}} = split(/,/, $dir);
		foreach $dir (@{$film->{directors}}) {
			$indexDirectors{$dir}{$mnr} = $mnr;
			if (!$indexDirectors{$dir}{count}) {
				$indexDirectors{$dir}{count} = 1;
			} else {
				$indexDirectors{$dir}{count} = $indexDirectors{$dir}{count} + 1;
			}
		}
		@{$film->{writers}} = split(/,/, $writers);
		@{$film->{soundtrackwriters}} = split(/,/, $soundtrackwriters);
		$line = <F>;
		$line = conv_line($line);
		# ASVF049954920150202121@00www.youtube.com/watch?v=8TNlvM4cN6U&hd=120160220
		# #!DT09037472015112516S01-S050www.imdb.com/video/imdb/vi338798873
		# NEU "genres": "CAVDYST0472033|123201501151210www.imdb.com/video/imdb/vi2476081689?ref_=tt_ov_vi",
		# NEU "genres": "ATH2948160|020190701181@00www.imdb.com/video/imdb/vi4029265945?playlistId=tt2948160&ref_=tt_ov_vi/m/corbin_nash"
		if ($line =~ m/^\s*"genres":\s*"(.*)",$/s) {
			$line = $1;
		}
		($film->{genre}, $film->{imdbfeld}, $film->{hinzu}, $film->{fsk}, $film->{staffeln}, $u, $u, $film->{trailer}, $film->{gesehen}, $film->{tomatolink}) = split(//, $line);
		$film->{tvserie} = 0;
		# ab v58 neben IMDB Nr auch die TOP Platzierung
		($film->{imdb}, $film->{imdbtop}) = split(/\|/, $film->{imdbfeld});
		if ($film->{imdb} eq "" || $film->{imdb} eq 0) {
			$film->{imdb} = 0;
			$film->{imdbtop} = 0;
		}
		if ($film->{imdbtop}) {
			$indexTopRated{$mnr} = $mnr;
		}
		if (!$film->{flag_gesehen}) {
			undef $film->{gesehen};
		}
		foreach $char (split(//, $film->{genre})) {
			if ($char eq "#") {
				$film->{tvserie} = 1;
				$film->{tvdat} = sprintf("%06d", $img);
				if (-s "../TVSeries/$film->{tvdat}/$film->{tvdat}.dat") {
					tvdat($film->{tvdat}, $mnr);
				} else {
					$film->{tvserie} = 0;
				}
			}
			$indexGenre{$char}{$mnr} = $mnr;
		}
		$film->{hinzusort} = $film->{hinzu};
		$film->{hinzu} = substr($film->{hinzu}, 6, 2) . '.' . substr($film->{hinzu}, 4, 2) . '.' . substr($film->{hinzu}, 0, 4);
		if ($film->{gesehen}) {
			$film->{gesehen} = substr($film->{gesehen}, 6, 2) . '.' . substr($film->{gesehen}, 4, 2) . '.' . substr($film->{gesehen}, 0, 4);
		}
		$indexFSK{$film->{fsk}}{$mnr} = $mnr;
		$line = <F>;
		$line = conv_line($line);
		# cEO0306G02B02 (=3 Oscars, 6 Oscars nominiert, 2 Golden Globes, 2 BAFTA-Awards
		# dEO1103G04B00
		# NEU "audio": "ddGEO0000G00B00",
		if ($line =~ m/^\s*"audio":\s*"(.*)",$/s) {
			$line = $1;
		}
		($film->{tonspur}, $u, $u, $oscar) = split(//, $line);
		$film->{award_oscar_win} = $film->{award_oscar_nom} = $film->{award_goldenglobe} = $film->{award_bafta} = 0;
		if ($oscar =~ m/O([0-9][0-9])([0-9][0-9])/) {
			if ($1 > 0) { $film->{award_oscar_win} = $1; $indexAward{$mnr} = $mnr; }
			if ($2 > 0) { $film->{award_oscar_nom} = $2; $indexAward{$mnr} = $mnr; }
		}
		if ($oscar =~ m/G([0-9][0-9])/) {
			if ($1 > 0) { $film->{award_goldenglobe} = $1; $indexAward{$mnr} = $mnr; }
		}
		if ($oscar =~ m/B([0-9][0-9])/) {
			if ($1 > 0) { $film->{award_bafta} = $1; $indexAward{$mnr} = $mnr; }
		}
		$line = <F>;
		$line = conv_line($line);
		# 833,275,581,834,835,836,837,838,839,840,316,841,842,843,4654,4655,4656,45703,4657,4658,4659,4660,4661,4662,4663,4664,4665,4666,4667,4668,18064,45704,45705,45706,27783,43690,45707,20993,45708,2020,45709,45710,25000,89378,45711,45712,45713,45714,45715,45716Jake Sully|Neytiri|Dr. Grace Augustine|Colonel Miles Quaritch|Trudy Chacón|Parker Selfridge|Norm Spellman|Moat|Eytukan|Tsu'tey|Dr. Max Patel|Corporal Lyle Wainfleet|Private Fike|Venture Star Crew Chief|Shuttle Pilot|Shuttle Co-Pilot|Shuttle Crew Chief|Dragon Gunship Pilot|Dragon Gunship Gunner|Dragon Gunship Navigator|Suit #1|Suit #2|Ambient Room Tech / Troupe|Ambient Room Tech|Ambient Room Tech / Troupe|Horse Clan Leader|Basketball Avatar / Troupe|Basketball Avatar|Troupe|Troupe|Troupe|Op Center Staff|Dancer|Dancer|Nav'i , uncredited|Ground Technician , uncredited|Flight Crew Mechanic , uncredited|Samson Pilot , uncredited|Trooper , uncredited|Banshee , uncredited|Soldier , uncredited|Ops Centreworker , uncredited|Col. Quaritch's Mech Suit , uncredited|OP Center Staff , uncredited|Ikran Clan Leader , uncredited|Geologist , uncredited|Na'vi , uncredited|Cryo Vault Med Tech|Lock Up Trooper|Tractor Operator / Troupe|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		# Achtung: bei Trickfilm kommt zu Actor 10.000.000 dazu - also jeweils prüfen - zB
		# 10012745,10001272,10013411,10012066,10001829,10014487,10005161,10002945,10013412,10024212,10025678,10020770,10020323,10014277,10011909,10012003,10003657,10025679,10014424,10004614,10017458,10014336,10025680,10001276,10025681,10011894,10016193,10025682,10025683,10014270,10008339,10016231,10011892,10006884,10038272,10012129,10016229,10014035,10059021,10012100,10053016,10037473,10012016,10014441,10052887,10059022,10052893,10053017,10059023,10059024|Horton|Mayor|Kangaroo|Vlad|Morton|Councilman / Yummo Wickersham|Dr. Mary Lou Larue|Tommy|Sally O'Malley|Mrs. Quilligan|Narrator|Rudy|Miss Yelp|JoJo|Who / Additional Voices|Another Who / Additional Voices|Who Mom / Additional Voices|Hildy / Holly|Wickersham Guard 1|Willie Bear / Additional Voices|Who Girl / Additional Voices|Helga|Obnoxious Who|Katie|Heidi / Haley|Glummox Mom / Additional Voices|Angela / Additional Voices|Jessica|The Dentist|Additional Voices|Additional Voices|Additional Voices|Additional Voices|Additional Voice|Additional Voices|Additional Voices|Additional Voices|Additional Voices|Hedy / Hooly / Additional Voices|Old Time Who / Additional Voices|Helen|Heather|Town Cryer / Additional Voices|Who Kid|Joe|Hanna / Additional Voices|Wickersham Guard 2|Who Child #1|Additional Voices|Additional Voice|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		# NEU "cast": "10000031,10000931,10000279,10000932,10000091,10000933,10000844,10000934,10000935,10000936#1|#2|#5|#6|#7|#8 / Radio Announcer|#9|Scientist|Dictator|News Caster|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||",
		if ($line =~ m/^\s*"cast":\s*"(.*)",$/s) {
			$line = $1;
		}
		foreach $actor (split(/,/, substr($line, 0, index($line, '')))) {
			if ($actor > 10000000) {
				$actor = $actor - 10000000 + 1;
			}
			push(@{$film->{actors}}, $actor);
		}
		@{$film->{roles}} = split(/\|/, substr($line, index($line, '')+1));
		
		foreach $actor (@{$film->{actors}}) {
			$indexActors{$actor}{$mnr} = $mnr;
			if (!$indexActors{$actor}{count}) {
				$indexActors{$actor}{count} = 1;
			} else {
				$indexActors{$actor}{count} = $indexActors{$actor}{count} + 1;
			}
		}
		# Ex-Marine Jake Sully nimmt auf dem Planeten Pandora an einem Experiment unter der Leitung der Wissenschaftlerin Dr. Grace Augustine teil. Als er sich im genetisch manipulierten Körper der Ureinwohner in die schöne Neytiri verliebt, gerät er zwischen die Fronten eines skrupellosen Konzerns und dem naturverbundenen Volk der Na'vi. Jake muss sich entscheiden, auf welcher Seite er steht - in einem ungleichen Kampf, in dem es um das Schicksal einer einzigartigen Welt geht ...
		# NEU "plot": "Schauplatz Zukunft: Eine übergreifende Maschine, bekannt unter dem Namen <DQ>Die große Maschine<DQ>, hat sich zusammen mit allen anderen Maschinen der Menschheit bemächtigt und diese komplett ausgelöscht. Doch unscheinbare kleine Wesen aus Stoff, erfunden von einem Wissenschaftler in den letzten Tagen des menschlichen Lebens, haben sich zu einer Mission zusammengeschlossen: in der Postapokalypse zu überleben. Nur eines von Ihnen, Nummer 9, hat die notwendigen Führungsqualitäten, um alle gemeinsam gegen die Maschinen aufzubringen. ",
		$line = <F>;
		$line = conv_line($line);
		if ($line =~ m/^\s*"plot": "(.*)",$/s) {
			$line = $1;
			$line =~ s/<DQ>/"/g;
			$film->{beschreibung} = $line;
			# wenn Plot, dann nächste Zeile für Comments einlesen
			$line = <F>;
			$line = conv_line($line);
		}
		
		# NEU "comments": "zu Dilogie kopieren - Equalizer",
		if ($line =~ m/^\s*"comments":\s*"(.*)",$/s) {
			$line = $1;
			$line =~ s/<DQ>/"/g;
			$film->{kommentar} = $line;
			# wenn Kommentar, dann nun nächste Zeile einlesen
			$line = <F>;
			$line = conv_line($line);
		}
		
		
		# 4F000A001CESG85359113414
		# 3B00190004EMG5532045050
		# NEU  "rating": "50000A0004EGE4510521638464"
		#      "rating": "4900190004EGG30215605169062"
		#  "rating": "3E00190004EGE41908130185060"  85% fresh + 60 meta
		if ($line =~ m/^\s*"rating":\s*"(.*)"$/s) {
			$line = $1;
		}
		($film->{imdbwertung}, $u, $u, $u, $film->{optionen}, $film->{sprachen}, $film->{untertitel}, $film->{anzahl_bewertungen}, $film->{mb}, $score) = split(//, $line);
		$indexGruppe{$film->{gruppe}}{'mb'} += $film->{mb};
		$film->{imdbwertung} = sprintf("%1.1f" , hex($film->{imdbwertung}) / 10);
		$film->{imdbganzwertung} = int $film->{imdbwertung};
		$indexIMDB{$film->{imdbganzwertung}}{$mnr} = $mnr;
		if (length($score) > 3) {
			if ($score =~ m/([0-9]{1,3})([0-9][0-9][0-9])/) {
				$film->{tomato} = $1;
				if ($film->{tomato} == 999) {
					$film->{tomato} = 0;
				}
				if ($film->{tomato} > 100) {
					$film->{tomato} -= 100;
					$film->{tomatofresh} = 1;
				} else {
					$film->{tomatofresh} = 0;
				}
				$film->{metascore} = int($2);
			} else {
				print "Das sollte nicht sein - score=$score\n";
				$film->{metascore} = $score;
			}
		} else {
			$film->{metascore} = $score;
		}
		$film->{metascore-rounded} = (int ($film->{metascore} / 10)) * 10;
		if ($film->{metascore-rounded} == 0 && $film->{metascore} == 0) {
			$film->{metascore-rounded} = "undef";
		}
		$indexMetascore{$film->{metascore-rounded}}{$mnr} = $mnr;
		if (hex($film->{optionen}) & 0b1000) {
			$film->{dreid} = "3D";
			$index3D{$mnr} = $mnr;
		} else {
			$film->{dreid} = "";
		}
				
		$indexImdbCount{$film->{imdb}.'_'.$film->{dreid}}{$mnr} = $mnr;
		if (!$indexImdbCount{$film->{imdb}.'_'.$film->{dreid}}{count}) {
			$indexImdbCount{$film->{imdb}.'_'.$film->{dreid}}{count} = 1;
		} else {
			$indexImdbCount{$film->{imdb}.'_'.$film->{dreid}}{count} = $indexImdbCount{$film->{imdb}.'_'.$film->{dreid}}{count} + 1;
		}
		if (int $film->{anzahl_bewertungen} == 0) {
			$film->{beliebtheit} = "000000";
		} elsif (int $film->{anzahl_bewertungen} < 100) {
			$film->{beliebtheit} = "000100";
		} elsif (int $film->{anzahl_bewertungen} < 1000) {
			$film->{beliebtheit} = "001000";
		} elsif (int $film->{anzahl_bewertungen} < 5000) {
			$film->{beliebtheit} = "005000";
		} elsif (int $film->{anzahl_bewertungen} < 10000) {
			$film->{beliebtheit} = "010000";
		} elsif (int $film->{anzahl_bewertungen} < 25000) {
			$film->{beliebtheit} = "025000";
		} elsif (int $film->{anzahl_bewertungen} < 50000) {
			$film->{beliebtheit} = "050000";
		} elsif (int $film->{anzahl_bewertungen} < 75000) {
			$film->{beliebtheit} = "075000";
		} elsif (int $film->{anzahl_bewertungen} < 100000) {
			$film->{beliebtheit} = "100000";
		} elsif (int $film->{anzahl_bewertungen} < 250000) {
			$film->{beliebtheit} = "250000";
		} else {
			$film->{beliebtheit} = "250001";
		}
		$indexBeliebtheit{$film->{beliebtheit}}{$mnr} = $mnr;
		
		# Abschluss zwei Zeilen mit RS - NEU Zeile mit  }, {
		$line = <F>;
		$FILME{$mnr} = $film;
		$mnr ++;
		#print Dumper($film);
		#exit 0;
	}
	$nr ++;
}
close (F);


# Ausgabe
mkdir("Movies", "755");
mkdir("Genres", "755");
mkdir("ActorsIndex", "755");
mkdir("DirectorsIndex", "755");
mkdir("Jahr", "755");
mkdir("FSK", "755");
mkdir("Zeit", "755");
mkdir("IMDB", "755");
mkdir("Gruppen", "755");
mkdir("Land", "755");
# zentrale Gliederungsdatei
open (T, ">typ.html") || die "Can't open typ.html - $!\n";
print T "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='list.css' type='text/css' rel='stylesheet'>
</head><body><div id='dvd'><h1><a href='index.html'>Meine Filme</a></h1> <h1>Film-&Uuml;bersichten</h1>";
$n = scalar keys %index3D;
print T '<div class="typ"><a href="Genres/3d.html" title="' . $n . ' Einträge">3-D Filme</a></div>&nbsp; ';
$n = scalar keys %indexFavorit;
print T '<div class="typ"><a href="Genres/favoriten.html" title="' . $n . ' Beiträge">Favoriten</a></div>&nbsp; ';
$n = scalar keys %indexAward;
print T '<div class="typ"><a href="Genres/awards.html" title="' . $n . ' Einträge">Ausgezeichnete Filme</a></div>&nbsp; ';
$n = scalar keys %indexTopRated;
print T '<div class="typ"><a href="Genres/top-rated.html" title="' . $n . ' Einträge">IMDB Top Plazierungen</a></div>&nbsp; ';
print T '<div class="typ"><a href="ActorsIndex/index.html">Alle Darsteller</a></div>&nbsp; ';
print T '<div class="typ"><a href="DirectorsIndex/index.html">Alle Regisseure</a></div>&nbsp; ';
print T '<div class="typ"><a href="lucky.html">Zufallsauswahl</a></div>&nbsp; ';
print T '<div class="typ"><a href="neu.html">Neue Filme</a></div>&nbsp; ';

print "Erzeuge Indizes: ";
# 3d Index
print "3D ";
open (D, ">Genres/3d.html") || die "Can't open 3d.html - $!\n";
# optional: <script src='../list.js'></script><script src='../list.pagination.js'></script><script src='../list.fuzzysearch.js'></script>
print D "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>3-D Filme <img src='../3d.png'></h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %index3D) {
	if ($nr =~ m/HASH/) { next ; }
	$rec = $FILME{$nr};
	if ($rec->{dreid}) {
		$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
	} else {
		$dreid = "";
	}
	if ($rec->{flag_favorit}) {
		$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
	} else {
		$showfavorit = '';
	}
	if ($rec->{flag_gesehen}) {
		$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
	} else {
		$showgesehen = '';
	}
	if ($indexAward{$nr}) {
		$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
	} else {
		$showaward = '';
	}
	print D '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
}
#optional: plugins: [ ListPagination({}), ListFuzzySearch() ]
print D "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
close (D);

# Favoriten Index
print "Favoriten ";
open (F, ">Genres/favoriten.html") || die "Can't open favoriten.html - $!\n";
# optional: <script src='../list.js'></script><script src='../list.pagination.js'></script><script src='../list.fuzzysearch.js'></script>
print F "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Favoriten <img src='../favorit.png'></h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %indexFavorit) {
	if ($nr =~ m/HASH/) { next ; }
	$rec = $FILME{$nr};
	if ($rec->{dreid}) {
		$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
	} else {
		$dreid = "";
	}
	if ($rec->{flag_favorit}) {
		$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
	} else {
		$showfavorit = '';
	}
	if ($rec->{flag_gesehen}) {
		$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
	} else {
		$showgesehen = '';
	}
	if ($indexAward{$nr}) {
		$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
	} else {
		$showaward = '';
	}
	print F '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
}
#optional: plugins: [ ListPagination({}), ListFuzzySearch() ]
print F "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
close (F);

# Awards Index
print "Awards ";
open (A, ">Genres/awards.html") || die "Can't open awards.html - $!\n";
# optional: <script src='../list.js'></script><script src='../list.pagination.js'></script><script src='../list.fuzzysearch.js'></script>
print A "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Ausgezeichnete Filme</h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %indexAward) {
	if ($nr =~ m/HASH/) { next ; }
	$rec = $FILME{$nr};
	if ($rec->{dreid}) {
		$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
	} else {
		$dreid = "";
	}
	if ($rec->{flag_favorit}) {
		$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
	} else {
		$showfavorit = '';
	}
	if ($rec->{flag_gesehen}) {
		$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
	} else {
		$showgesehen = '';
	}
	if ($indexAward{$nr}) {
		$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
	} else {
		$showaward = '';
	}
	print A '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
}
#optional: plugins: [ ListPagination({}), ListFuzzySearch() ]
print A "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
close (A);

# TOP rated Index
print "IMDB-TOP ";
open (A, ">Genres/top-rated.html") || die "Can't open top-rated.html - $!\n";
# optional: <script src='../list.js'></script><script src='../list.pagination.js'></script><script src='../list.fuzzysearch.js'></script>
print A "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>IMDB Top Plazierungen <img src='../top-rated.png' border='0'></h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td class='top'><button class='sort' data-sort='top'>IMDB TOP</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
foreach $nr (sort {int($FILME{$a}->{imdbtop}) <=> int($FILME{$b}->{imdbtop})} keys %indexTopRated) {
	if ($nr =~ m/HASH/) { next ; }
	$rec = $FILME{$nr};
	if ($rec->{dreid}) {
		$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
	} else {
		$dreid = "";
	}
	if ($rec->{flag_favorit}) {
		$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
	} else {
		$showfavorit = '';
	}
	if ($rec->{flag_gesehen}) {
		$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
	} else {
		$showgesehen = '';
	}
	if ($indexAward{$nr}) {
		$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
	} else {
		$showaward = '';
	}
	print A '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td class="top">' . $rec->{imdbtop} .'</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
}
#optional: plugins: [ ListPagination({}), ListFuzzySearch() ]
print A "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'top', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
close (A);


# Genre-Dateien
print "Genre ";
print T "<h1>Genre</h1>";
foreach $genre (sort {$genreclear{$a} cmp $genreclear{$b}}keys %indexGenre) {
	if ($genre =~ m/HASH/) { next ; }
	if ($genrefile{$genre} eq "") { next ; }
	$n = scalar keys %{$indexGenre{$genre}};
	print T '<div class="typ"><a href="Genres/' . $genrefile{$genre} . '.html" title="' . $n . ' Einträge">' . $genreclear{$genre} . '</a></div>&nbsp; ';
	open (G, ">Genres/$genrefile{$genre}.html") || die "Can't open grenrefile $genre - $!\n";
	if ($genre eq "#") {
		$tvimg = " <img src='../tv.png' border='0' title='TV-Serie'>";
	} else {
		$tvimg = "";
	}
	print G "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Genre " . $genreclear{$genre} . $tvimg . "</h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexGenre{$genre}}) {
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print G '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta"><span class="meta">' . $rec->{metascore} . '</span></span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print G "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (G);
}

# IMDB-Dateien
print "IMDB ";
print T "<h1>IMDB-Bewertung</h1>";
foreach $imdb (sort keys %indexIMDB) {
	if ($imdb =~ m/HASH/) { next ; }
	$n = scalar keys %{$indexIMDB{$imdb}};
	print T '<div class="typ"><a href="IMDB/' . $imdb . '.html" title="' . $n . ' Einträge">' . $imdb . '.0 bis ' . $imdb . '.9</a></div>&nbsp; ';
	open (I, ">IMDB/$imdb.html") || die "Can't open imdb/$imdb.html - $!\n";
	print I "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>IMDB-Wertung " . $imdb . ".0 bis " . $imdb . ".9</h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexIMDB{$imdb}}) {
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print I '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta"><span class="meta">' . $rec->{metascore} . '</span></span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print I "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (I);
}

# Metascore-Dateien
print "Metascore ";
print T "<h1>Metascore</h1>";
foreach $metascore (sort keys %indexMetascore) {
	if ($metascore =~ m/HASH/) { next ; }
	
	$metascore9 = $metascore + 9;
	$n = scalar keys %{$indexMetascore{$metascore}};
	if ($metascore =~ m/undef/) {
		print T '<div class="typ"><a href="IMDB/meta-' . $metascore . '.html" title="' . $n . ' Einträge">Nicht ermittelt</a></div>&nbsp; ';
	} else {
		print T '<div class="typ"><a href="IMDB/meta-' . $metascore . '.html" title="' . $n . ' Einträge">' . $metascore . ' bis ' . $metascore9 . '</a></div>&nbsp; ';
	}
	open (M, ">IMDB/meta-$metascore.html") || die "Can't open IMDB/meta-$metascore.html - $!\n";
	print M "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> ";
	if ($metascore =~ m/undef/) {
		print M "<h1>Metascore nicht ermittelt</h1>";
	} else {
		print M "<h1>Metascore " . $metascore . " bis " . $metascore9 . "</h1>";
	}
	print M "<table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexMetascore{$metascore}}) {
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print M '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta"><span class="meta">' . $rec->{metascore} . '</span></span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print M "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (M);
}


# IMDB-Beliebtheit-Dateien
print "IMDB-Beliebtheit ";
print T "<h1>Beliebtheit nach Anzahl der IMDB-Bewertungen</h1>";
foreach $beliebtheit (sort keys %indexBeliebtheit) {
	if ($beliebtheit =~ m/HASH/) { next ; }
	if ($beliebtheit eq "000000") { next ; }
	$n = scalar keys %{$indexBeliebtheit{$beliebtheit}};
	print T '<div class="typ"><a href="IMDB/' . $beliebtheit . '.html" title="' . $n . ' Einträge">' . $beliebtheitName{$beliebtheit} . '</a></div>&nbsp; ';
	open (B, ">IMDB/$beliebtheit.html") || die "Can't open imdb/$beliebtheit.html - $!\n";
	print B "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Beliebtheit nach Anzahl der IMDB-Wertungen " . $beliebtheitName{$beliebtheit} . "</h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='beliebtheit'><button class='sort' data-sort='beliebtheit'>Beliebtheit</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexBeliebtheit{$beliebtheit}}) {
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print B '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta"><span class="meta">' . $rec->{metascore} . '</span></a></td><td class="beliebtheit">' . $rec->{anzahl_bewertungen} . '</td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print B "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'beliebtheit', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (B);
}

# FSK-Dateien
print "FSK ";
print T "<h1>FSK-Freigabe</h1>";
foreach $fsk (sort keys %indexFSK) {
	if ($fsk =~ m/HASH/) { next ; }
	if ($fsk eq "") { next ; }
	$n = scalar keys %{$indexFSK{$fsk}};
	print T '<div class="typ"><a href="FSK/' . $fsk . '.html" title="' . $n . ' Einträge">' . $fsk . '</a></div>&nbsp; ';
	# open (F, ">FSK/$fsk.html") || die "Can't open fsk/$fsk.html - $!\n";
	open (F, ">FSK/$fsk.html") ;
	print F "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>FSK " . $fsk . "</h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexFSK{$fsk}}) {
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print F '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print F "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (F);
}

# Land-Dateien
print "Land ";
print T "<h1>Land</h1>";
foreach $land (sort {$landcode{$a} cmp $landcode{$b}}keys %indexLand) {
	if ($land =~ m/HASH/) { next ; }
	if ($land eq "") { next ; }
	$n = scalar keys %{$indexLand{$land}};
	print T '<div class="typ"><a href="Land/' . $land . '.html" title="' . $n . ' Einträge">' . $landcode{$land} . '</a></div>&nbsp; ';
	# open (L, ">Land/$land.html") || die "Can't open land/$land.html - $!\n";
	open (L, ">Land/$land.html");
	print L "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Land " . $landcode{$land} . "</h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexLand{$land}}) {
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print L '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print L "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (L);
}

# Actors-Dateien
print "Actors ";
$firstchar = '';
#open (AI, ">ActorsIndex/index.html") || die "Can't open ActorsIndex - $!\n";
open (AI, ">ActorsIndex/index.html");
print AI "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Alle Darsteller</h1><table>
	<thead><tr><td><button class='sort' data-sort='headshotmini'>Bild</button></td><td><button class='sort' data-sort='actor'>Darsteller</button> <input class='search' placeholder='Suche'/></td><td class='anzahl'><button class='sort' data-sort='anzahl'>Anzahl</button></td></tr></thead>
    <tbody class='list'>\n";
foreach $actor (sort {lc($ACTORS[$a]) cmp lc($ACTORS[$b])} keys %indexActors) {
	if ($indexActors{$actor}{count} >= $MINACTORS) {
	if ($ACTORS[$actor]) {
		print AI '<tr>';
		if ($ACTORSHEADSHOT[$actor]) {
			print AI "<td><span class='headshotmini'><img src='../" . $ACTORSHEADSHOT[$actor] . "' class='headshotmini'></span></td>";
		} else {
			print AI "<td><span class='headshotmini' style='display:none'>ZZZZZ " . $ACTORS[$actor] . "</span></td>";
		}
		print AI '<td><a href="' . $actor . '.html"><span class="actor">' . $ACTORS[$actor] . '</span></a></td><td class="anzahl">' . $indexActors{$actor}{count} . "</td></tr>\n";
	}
	$myfirst = substr($ACTORS[$actor], 0, 1);
	if ($firstchar ne $myfirst) {
		print $myfirst;
		$firstchar = $myfirst;
	}
	#open (A, ">ActorsIndex/$actor.html") || die "Can't open ActorsIndex/$actor.html - $!\n";
	open (A, ">ActorsIndex/$actor.html") ;
	print A "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1>";
	if ($ACTORSHEADSHOT[$actor]) {
		print A "<img src='../" . $ACTORSHEADSHOT[$actor] . "' class='headshot'> ";
	}
	print A " <h1>Darsteller " . $ACTORS[$actor] . " <a href='http://www.moviepilot.de/people/" . txt2url($ACTORS[$actor]). "' target='_blank'><img src='../mp-klein.png' title='Suche auf MoviePilot' border=0></a>";
	if ($ACTORSID[$actor]) {
		print A "  <a href='https://www.imdb.com/name/nm" . $ACTORSID[$actor] . "'><img src='../imdb.png' border='0' alt='IMDB-Link'></a>";
	}
	print A "</h1><br clear=all><p><a href='index.html'>Alle Darsteller</a></p><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexActors{$actor}}) {
		if ($nr eq "count") { next; }
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print A '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print A "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (A);
	}
}
print AI "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'headshotmini', 'actor', 'anzahl' ],
  page: 10,
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script></body></html>";
close (AI);

# Jahr-Dateien
print "Jahr ";
print T "<h1>Jahr</h1>";
foreach $jahr (sort keys %indexJahr) {
	if ($jahr =~ m/HASH/) { next ; }
	if ($jahr eq "") { next ; }
	$n = scalar keys %{$indexJahr{$jahr}};
	print T '<div class="typ"><a href="Jahr/' . $jahr . '.html" title="' . $n . ' Einträge">' . $jahr . '</a></div>&nbsp; ';
	#open (J, ">Jahr/$jahr.html") || die "Can't open jahr/$jahr.html - $!\n";
	open (J, ">Jahr/$jahr.html");
	print J "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Jahr " . $jahr . "</h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexJahr{$jahr}}) {
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print J '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print J "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (J);
}
# Zeit-Dateien
print "Zeit ";
print T "<h1>Dauer</h1>";
foreach $zeit (sort keys %indexZeit) {
	if ($zeit =~ m/HASH/) { next ; }
	$n = scalar keys %{$indexZeit{$zeit}};
	print T '<div class="typ"><a href="Zeit/' . $zeit . '.html" title="' . $n . ' Einträge">' . $zeitName{$zeit} . '</a></div>&nbsp; ';
	#open (Z, ">Zeit/$zeit.html") || die "Can't open zeit/$zeit.html - $!\n";
	open (Z, ">Zeit/$zeit.html") ;
	print Z "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Dauer " . $zeitName{$zeit} . "</h1><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexZeit{$zeit}}) {
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print Z '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print Z "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (Z);
}

# Gruppen-Dateien
print "Gruppen ";
print T "<h1>Gruppen</h1>";
open (G2, ">gruppen-utf8.csv") || die "Can't open gruppen-utf8.csv - $!\n";
print G2 "Gruppe;Anzahl;Minuten;Stunden;MB;GB\n";
foreach $gruppe (sort keys %indexGruppe) {
	if ($gruppe =~ m/HASH/) { next ; }
	$fgruppe = txt2url($gruppe);
	if ($fgruppe eq "") { next ; }
	if ($fgruppe eq ".") { next ; }
	$n = scalar keys %{$indexGruppe{$gruppe}};
	print T '<div class="typ"><a href="Gruppen/' . $fgruppe . '.html" title="' . $indexGruppe{$gruppe}{'count'} . ' Einträge">' . $gruppe . '</a></div>&nbsp; ';
	#open (G, ">Gruppen/$fgruppe.html") || die "Can't open gruppe/$fgruppe.html - $!\n";
	open (G, ">Gruppen/$fgruppe.html") ;
	print G "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1><img src='../gruppe.png'> Gruppe '" . $gruppe . "'</h1>";
	$dauermin = $indexGruppe{$gruppe}{'dauer'};
	$dauerstd =  int(10 * $indexGruppe{$gruppe}{'dauer'} / 60 + 0.5)/10;
	$dauerstd =~ s/\./,/;
	$mb = $indexGruppe{$gruppe}{'mb'};
	$gb = int (100 * $indexGruppe{$gruppe}{'mb'} / 1024 + 0.5)/100;
	$gb =~ s/\./,/;
	print G "<p>Anzahl der Filme: ". $indexGruppe{$gruppe}{'count'} . ", Gesamtdauer der Filme: $dauermin Minuten oder $dauerstd Stunden,  Gesamtgröße der Filme: $mb MB bzw. $gb GB</p>";
	print G2 "\"" . $gruppe . "\";" . $indexGruppe{$gruppe}{'count'} . ";" . $dauermin . ";" . $dauerstd . ";" . $mb . ";" . $gb . "\n";
	print G "<table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexGruppe{$gruppe}}) {
		if ($nr eq "dauer") { next ; }
		if ($nr eq "count") { next ; }
		if ($nr eq "mb") { next ; }
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print G '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print G "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (G);
}

# Abschluss Gliederung</body></html>";
print T "</body></html>";
close (T);
close (G2);

# Doppelte Filme
print "Doppelt ";
open (D, ">Genres/doppelt.html") || die "Can't open doppelt.html - $!\n";
print D "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Filme ohne IMDB-Zuordnung und doppelte Filme</h1><table>
	<thead><tr><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='pfad'><button class='sort' data-sort='pfad'>Pfad</button></td></tr></thead>
    <tbody class='list'>\n";
foreach $imdb (sort {int($a) <=> int($b)} keys %indexImdbCount) {
	if ($imdb =~ m/HASH/) { next ; }
	if ($indexImdbCount{$imdb}{count} == 1) { next ; }
	foreach $nr (reverse sort {int($a) <=> int($b)} keys %{$indexImdbCount{$imdb}}) {
		if ($nr eq "count") { next; }
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
			$dreid = "";
		}
		print D '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="imdb">' . $rec->{imdb} . '</td><td class="nr">' . $nr . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td class="pfad">' . $rec->{pfad} . "</td></tr>\n";
	}
}
print D "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'imdb', 'nr', 'titel', 'jahr', 'reso', 'pfad' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
close (D);	
		
# Directors-Dateien
print "Directors\n";
open (DI, ">DirectorsIndex/index.html") || die "Can't open DirectorsIndex - $!\n";
print DI "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1> <h1>Alle Regisseure</h1><table>
	<thead><tr><td><button class='sort' data-sort='headshotmini'>Bild</button></td><td><button class='sort' data-sort='director'>Regisseur</button> <input class='search' placeholder='Suche'/></td><td class='anzahl'><button class='sort' data-sort='anzahl'>Anzahl</button></td></tr></thead>
    <tbody class='list'>\n";
foreach $dir (sort {lc($DIRECTORS[$a]) cmp lc($DIRECTORS[$b])} keys %indexDirectors) {
	if ($indexDirectors{$dir}{count} >= $MINDIRECTORS) {
	print DI '<tr>';
	if ($DIRECTORSHEADSHOT[$dir]) {
		print DI "<td><span class='headshotmini'><img src='../../Headshots/" . $DIRECTORSHEADSHOT[$dir] . "' class='headshotmini'></span></td>";
	} else {
		print DI "<td><span class='headshotmini' style='display:none'>ZZZZZ " . $DIRECTORS[$dir] . "</span></td>";
	}
	print DI '<td><a href="' . $dir . '.html"><span class="director">' . $DIRECTORS[$dir] . '</span></a></td><td class="anzahl">' . $indexDirectors{$dir}{count} . "</td></tr>\n";
	#open (D, ">DirectorsIndex/$dir.html") || die "Can't open DirectorsIndex/$dir.html - $!\n";
	open (D, ">DirectorsIndex/$dir.html");
	
	print D "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='../list.css' type='text/css' rel='stylesheet'><script src='../imagehover-p.js'></script><script src='../list.js'></script><script src='../list.pagination.js'></script>
</head><body><div id='dvd'><h1><a href='../index.html'>Meine Filme</a></h1>";
	if ($DIRECTORSHEADSHOT[$dir]) {
		print D "<img src='../../Headshots/" . $DIRECTORSHEADSHOT[$dir] . "' class='headshot'> ";
	}
	print D " <h1>Regisseur " . $DIRECTORS[$dir] . " <a href='http://www.moviepilot.de/people/" . txt2url($DIRECTORS[$dir]). "' target='_blank'><img src='../mp-klein.png' title='Suche auf MoviePilot' border=0></a></h1><p><a href='index.html'>Alle Regisseure</a></p><br clear=all><table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>\n";
	foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexDirectors{$dir}}) {
		if ($nr eq "count") { next; }
		$rec = $FILME{$nr};
		if ($rec->{dreid}) {
			$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
		} else {
		$dreid = "";
		}
		if ($rec->{flag_favorit}) {
			$showfavorit = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
		} else {
			$showfavorit = '';
		}
		if ($rec->{flag_gesehen}) {
			$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="../gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
		} else {
			$showgesehen = '';
		}
		if ($indexAward{$nr}) {
			$showaward = ' <a href="../Genres/awards.html"><img src="../award.png" border="0" alt="Ausgezeichnet!"></a>'; 
		} else {
			$showaward = '';
		}
		print D '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="../Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="../Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="../FSK/' . $rec->{fsk} . '.html">' . $rec->{fsk} . '</a></td><td><a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="../IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="../Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	}
	print D "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
	close (D);
	}
}
print DI "</tbody></table><ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'headshotmini', 'director', 'anzahl' ],
  page: 10,
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script></body></html>";
close (DI);

# Haupt-Index und einzelne Filmdateien
open (F, ">index.html") || die "Can't open index.html - $!\n";
open (L, ">lucky.html") || die "Can't open lucky.html - $!\n";
open (N, ">neu.html") || die "Can't open neu.html - $!\n";
open (C, ">tabelle-utf8.csv") || die "Can't open tabelle-utf8.csv - $!\n";


my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime;
my $stand = sprintf "%02d.%02d.%04d", $mday, $mon+1, $year+1900;

print F "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='list.css' type='text/css' rel='stylesheet'><script src='imagehover.js'></script><script src='list.js'></script><script src='list.pagination.js'></script>
</head>
<body>
<div id='dvd'>
  <h1>Meine Filme <small><small>Stand: $stand</small></small></h1>
  <p>&nbsp;<a href='typ.html'>Film-Übersichten</a>&nbsp;&nbsp;&nbsp;<a href='ActorsIndex/index.html'>Alle Darsteller</a>&nbsp;&nbsp;&nbsp;<a href='DirectorsIndex/index.html'>Alle Regisseure</a>&nbsp;&nbsp;&nbsp;<a href='lucky.html'>Zufallsauswahl ungesehener Filme</a>&nbsp;&nbsp;&nbsp;<a href='neu.html'>Neue Filme</a>&nbsp;&nbsp;&nbsp;<a href='Genres/favoriten.html'>Favoriten <img src='favorit.png' border='0'></a>&nbsp;&nbsp;&nbsp;<a href='tabelle.csv'>CSV-Tabelle <img src='csv.png' border='0'></a></p>
  <table>
	<thead><tr><td class='nr'><button class='sort' data-sort='nr'>Nr.</button></td><td><button class='sort' data-sort='titel'>Titel</button> <input class='search' placeholder='Suche'/></td><td class='jahr'><button class='sort' data-sort='jahr'>Jahr</button></td><td class='fsk'><button class='sort' data-sort='fsk'>FSK</button></td><td class='dauer'><button class='sort' data-sort='dauer'>Minuten</button></td><td class='reso'><button class='sort' data-sort='reso'>Aufl&ouml;sung</button></td><td class='imdb'><button class='sort' data-sort='imdb'>IMDB</button></td><td class='meta'><button class='sort' data-sort='meta'>Meta</button></td><td class='genre'><button class='sort' data-sort='genre'>Genre</button></td></tr></thead>
    <tbody class='list'>";

print L "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='list.css' type='text/css' rel='stylesheet'>
</head>
<body>
  <h1><a href='index.html'>Meine Filme</a></h1> <h1><a href='' title='Neue Zufallsauswahl laden' onClick='location.reload()'><img src='refresh.gif' border='0' style='vertical-align: bottom;'></a>&nbsp;&nbsp;Zufallsauswahl ungesehener Filme</h1><script>var MOVIES = new Array();";

print N "<html><head><meta http-equiv='content-type' content='text/html; charset=utf-8'><link href='list.css' type='text/css' rel='stylesheet'>
</head>
<body>
<div id='dvd'><h1><a href='index.html'>Meine Filme</a></h1> <h1>Neue Filme</h1>\n";

print C "Nr;Titel;Original Titel;Platte;Pfad;Hinzugefügt;Gesehen;Jahr;FSK;Dauer;Auflösung;Größe in MB;Land;IMDB Wertung;IMDB Anzahl;Tomatometer;Metascore;Genres;Kommentar;Oscar gewonnen;Oscar nominiert;GoldenGlobe;BAFTA\n";

$lucky = 0;	
print "Erzeuge Filmdateien: ...\n";
foreach $nr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %FILME) {
	if ($nr eq "count") { next; }
	if ($nr eq "dauer") { next; }
	if ($nr eq "mb") { next; }
	if ($nr =~ m/HASH/) { next ; }
	$rec = $FILME{$nr};
	if ($rec->{dreid}) {
		$dreid = "&nbsp;&nbsp;<a href='Genres/3d.html'><img src='3d.png' title='3-D Film' class='ddd' border='0'></a>";
		$dreid2 = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>"
	} else {
		$dreid = "";
		$dreid2 = "";
	}
	if ($rec->{tvserie}) {
		$tvserie = "&nbsp;&nbsp;<a href='Genres/tv-serie.html'><img src='tv.png' title='TV-Serie ($rec->{staffeln})' class='tv' border='0'></a>";
		$tvserie2 = "&nbsp;&nbsp;<a href='../Genres/tv-serie.html'><img src='../tv.png' title='TV-Serie ($rec->{staffeln})' class='tv' border='0'></a>";
		$ptitel = "<a href='../TVDat/" . $rec->{tvdat} . ".html'>" . $rec->{titel} . "</a>";
		$pptitel = "<a href='../TVDat/" . $rec->{tvdat} . ".html'>" . $rec->{ptitel} . "</a>";
	} else {
		$tvserie = "";
		$tvserie2 = "";
		$ptitel = $rec->{titel};
		$pptitel = $rec->{ptitel};
	}
	foreach $char (split(//, $rec->{genre})) {
		$rec->{genres} .= $genreclear{$char} . " ";
	}
	# Filmzeile in Hauptliste
	if ($rec->{otitel}) {
		$potitel = ' <div class="otitel">' . $rec->{otitel} . '</div>';
	} else {
		$potitel = '';
	}
	if ($rec->{flag_favorit}) {
		$showfavorit = ' <a href="Genres/favoriten.html"><img src="favorit.png" border="0" alt="Favorit"></a>'; 
		$showfavorit2 = ' <a href="../Genres/favoriten.html"><img src="../favorit.png" border="0" alt="Favorit"></a>'; 
	} else {
		$showfavorit = '';
		$showfavorit2 = '';
	}
	if ($rec->{flag_gesehen}) {
		$showgesehen = ' <span title="gesehen am ' . $rec->{gesehen} . '"><img src="gesehen.png" border="0" alt="&deg;&deg;"></span>'; 
	} else {
		$showgesehen = '';
	}
	if ($indexAward{$nr}) {
		$showaward = ' <a href="Genres/awards.html"><img src="award.png" border="0" alt="Ausgezeichnet!"></a>'; 
	} else {
		$showaward = '';
	}
	if ($rec->{kommentar}) {
		$showkommentar = ' <span title="' . $rec->{kommentar} . '"><img src="kommentar.png" border="0" alt="Kommentar" align="right"></span>';
		$kommkommentar = 'Kommentar: ' . $rec->{kommentar};
	} else {
		$showkommentar = '';
		$kommkommentar = '';
	}
	
	
	print F '<tr onmouseover="loading(\'' . $rec->{cover} . '\')" onmouseout="hide(\'' . $rec->{cover} . '\')"><td class="nr" title="' . $rec->{groupslist} . $rec->{pfad} . '">' . $nr . $showgesehen . $showfavorit . '</td><td><a href="Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '<!--' . $potitel . ' ' . $kommkommentar . '--></span>' . $potitel . '</a>' . $dreid . $tvserie . '<a href="Gruppen/' . txt2url($rec->{gruppe}). '.html"><img src="gruppe.png" border="0" align="right"></a>' . $showkommentar. '</td><td><a href="Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="FSK/' . $rec->{fsk} . '.html">'. $rec->{fsk} . '</a></td><td><a href="Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td><a href="IMDB/' . $rec->{imdbganzwertung} . '.html"><span class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10<span></a>' . $showaward . '</td><td><a href="IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></td><td><a href="Genres/' . $genrefile{substr($rec->{genre}, 0, 1)} . '.html"><span class="genre" title="' . $rec->{genres} . '">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</span></a></td></tr>\n";
	
	$cimdb = $rec->{imdbwertung};
	$cimdb =~ s/\./,/g;
	
	print C $nr . ';"' . $rec->{titel} . '";"' . $rec->{otitel} . '";' . $rec->{groupslist} . ';' . $rec->{pfad} . ';' . $rec->{hinzu} . ';' . $rec->{gesehen} . ';' .  $rec->{jahr} . ';' . $rec->{fsk} . ';' . $rec->{dauer} . ';' . $rec->{reso} . ';' . $rec->{mb} . ';"' . $landcode{txt2url($rec->{land})} . '";' . $cimdb . ';' . $rec->{anzahl_bewertungen} . ';' . $rec->{tomato} . ';' . $rec->{metascore} . ';"' .$rec->{genres} . '";"' . $rec->{kommentar} . '";' . $rec->{award_oscar_win} . ';' . $rec->{award_oscar_nom} . ';' . $rec->{award_goldenglobe} . ';' . $rec->{award_bafta} . "\n";
		
	# Array für Zufallsauswahl füllen
	if (!$rec->{gesehen}) {
		$ltitel = $rec->{ptitel};
		$ltitel =~ s/'/\\'/g;
		$lucky++;
		print L 'MOVIES[' . $lucky . '] = \'<div class="lucky"><a href="Movies/' . $nr . '.html"><img src="../Covers/' . $rec->{cover} . '" class="lucky"><br clear=all>' . $ltitel . ' </a></div>\';' . "\n";
	}
		
	# Film-HTML
	open (M, ">Movies/$nr.html") || die "Can't write Movies/$nr.html - $!\n";
	print M '<html><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><link href="../list.css" type="text/css" rel="stylesheet"><script src="../list.js"></script></head><body><h1><a href="../index.html">Meine Filme</a></h1> <h1><small><small>#' . $nr . '</small></small> ' . $pptitel . $dreid2 . $tvserie2 . $showfavorit2 . '</h1>';
	if ($rec->{otitel}) {
		print M '<p><i>Alternativ: ' . $rec->{otitel} . "</i><br>";
	}
	if ($indexAward{$nr}) {
		print M 'Auszeichnungen:';
		if ($rec->{award_oscar_win}) { printf M ' %d Oscars gewonnen', $rec->{award_oscar_win}; }
		if ($rec->{award_oscar_nom}) { printf M ' f&uuml;r %d Oscars nominiert', $rec->{award_oscar_nom}; }
		if ($rec->{award_goldenglobe}) { printf M ' %d GoldenGlobes gewonnen', $rec->{award_goldenglobe}; }
		if ($rec->{award_bafta}) { printf M ' %d BAFTA-Awards gewonnen', $rec->{award_bafta}; }
		print M '<br>';
	}
	if ($rec->{gesehen}) { print M "<img src='../gesehen.png' border='0'> gesehen am " . $rec->{gesehen} . "<br>"; }
	print M "<br></p>\n";
	print M '<p><a href="../../Posters/' . $rec->{cover} . '" target="_blank"><img src="../../Covers/' . $rec->{cover} . '" class="cover"></a> <a href="http://' . $rec->{trailer} . '" target="_blank"><img src="../youtube.png" border="0" title="Trailer"></a>&nbsp;&nbsp;&nbsp;<a href="http://www.imdb.com/title/tt' . $rec->{imdb} . '" target="_blank"><img src="../imdb.png" border="0" title="IMDB"></a> <i><small>IMDB-Wertung:</small> <a href="../IMDB/' . $rec->{imdbganzwertung} . '.html" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10</a></i>';
	if ($rec->{imdbtop}) {
		print M '&nbsp;&nbsp;&nbsp;<img src="../top-rated.png" border="0">&nbsp;<i><small>IMDB-TOP-Platzierung:</small> <a href="../Genres/top-rated.html">' . $rec->{imdbtop} . '</a></i>';
	}
	if ($rec->{tomato} && $rec->{tomatofresh}) {
		print M '&nbsp;&nbsp;&nbsp;<a href="https://www.rottentomatoes.com' . $rec->{tomatolink} . '"><img src="../tomatofresh.png" border="0"></a>&nbsp;<i><small>Tomatometer:</small> <span class="tomato">' . $rec->{tomato} . '</span></i>';
	} elsif ($rec->{tomato} >= 60) {
		print M '&nbsp;&nbsp;&nbsp;<a href="https://www.rottentomatoes.com' . $rec->{tomatolink} . '"><img src="../tomato.png" border="0"></a>&nbsp;<i><small>Tomatometer:</small> <span class="tomato">' . $rec->{tomato} . '</span></i>';
	} elsif ($rec->{tomato}) {
		print M '&nbsp;&nbsp;&nbsp;<a href="https://www.rottentomatoes.com' . $rec->{tomatolink} . '"><img src="../tomatosplat.png" border="0"></a>&nbsp;<i><small>Tomatometer:</small> <span class="tomato">' . $rec->{tomato} . '</span></i>';
	}
	if ($rec->{metascore} ne "undef") {
		print M '&nbsp;&nbsp;&nbsp;<img src="../metascore.png" border="0"><i><small>Metascore:</small> <a href="../IMDB/meta-' . $rec->{metascore-rounded} . '.html"><span class="meta">' . $rec->{metascore} . '</span></a></i>';
	}
	print M '&nbsp;&nbsp;&nbsp;<a href="http://www.moviepilot.de/suche?type=movie&q=' . $rec->{titel} . '" target="_blank"><img src="../mp-klein.png" title="MoviePilot" border="0"></a><br><br>' . $rec->{beschreibung} . '<br><i>' . $rec->{kommentar} . "</i><br clear=all></p>\n";
	print M '<p>Jahr: <a href="../Jahr/' . $rec->{jahr} . '.html">' . $rec->{jahr} . '</a><br>Dauer: <a href="../Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '">' . $rec->{dauer} . " Minuten</a><br>FSK: <a href='../FSK/" . $rec->{fsk} . ".html'>". $rec->{fsk} . "</a><br>";
	print M 'Land: <a href="../land/' . txt2url($rec->{land}) . '.html">' . $landcode{txt2url($rec->{land})} . '</a> Studio: ' . $rec->{studio} . '</br>';
	print M 'Tonspuren: ';
	$n = length($rec->{tonspur}) / 2;
	for ($i = 1; $i le $n; $i++) {
		print M "$toncode{substr($rec->{tonspur}, $i-1, 1)} - $sprachcode{substr($rec->{tonspur}, $n+$i-1, 1)}, "
	}
	print M '<br>Untertitel: ';
	$unter = reverse($rec->{untertitel});
	while ($u = chop($unter)) {
		print M $sprachcode{$u} . ", ";
	}
	print M '<br>Aufl&ouml;sung: ' . $rec->{reso} . ' <small>(' . $rec->{resolution} . ')</small>  Gr&ouml;&szlig;e: ' . $rec->{mb} . ' MB<br>';
	print M "<br><p>Genre: ";
	$first = 1;
	foreach $char (split(//, $rec->{genre})) {
		if (!$first) {
			print M ", ";
		} else {
			$first = 0;
		}
		print M '<a href="../Genres/' . $genrefile{$char} . '.html">' . $genreclear{$char} . "</a>";
	}
	print M "</p>\n";
	print M "<p>Regisseur: ";
	$first = 1;
	foreach $dir (@{$rec->{directors}}) {
		if (!$first) {
			print M ", ";
		} else {
			$first = 0;
		}
		if ($indexDirectors{$dir}{count} >= $MINDIRECTORS) {
			if ($DIRECTORSHEADSHOT[$dir]) {
				print M '<img src="../../Headshots/' . $DIRECTORSHEADSHOT[$dir] . '" class="headshotmini"> ';
			}
			print M '<a href="../DirectorsIndex/' . $dir . '.html">' . $DIRECTORS[$dir] . "</a>";
		} else {
			print M $DIRECTORS[$dir];
		}
		$i++;
	}
	print M "</p>\n";
	print M "<p>Drehbuch: ";
	$first = 1;
	foreach $writer (@{$rec->{writers}}) {
		if (!$first) {
			print M ", ";
		} else {
			$first = 0;
		}
		print M $WRITERS[$writer];
	}
	print M "</p>\n";
	print M "<p>Soundtrack: ";
	$first = 1;
	foreach $soundtrackwriter (@{$rec->{soundtrackwriters}}) {
		if (!$first) {
			print M ", ";
		} else {
			$first = 0;
		}
		print M $SOUNDTRACKWRITERS[$soundtrackwriter];
	}
	print M "</p>\n";
	print M "<p>Darsteller:</p><ul>\n";
	$i = 0;
	foreach $ac (@{$rec->{actors}}) {
		if ($indexActors{$ac}{count} >= $MINACTORS) {
			print M '<li>';
			if ($ACTORSHEADSHOT[$ac]) {
				print M '<img src="../' . $ACTORSHEADSHOT[$ac] . '" class="headshotmini"> ';
			} else {
				print M "<span class='headshotmini'>&nbsp;</span>";
			}
			print M '<a href="../ActorsIndex/' . $ac . '.html">' . $ACTORS[$ac] . "</a> <small>als</small> <i>" . $rec->{roles}[$i] . "</i></li>\n";
		} else {
			print M '<li><span class="headshotmini">&nbsp;</span>' . $ACTORS[$ac] . " <small>als</small> <i>" . $rec->{roles}[$i] . "</i></li>\n";
		}
		$i++;
	}
	print M "</ul></p>";
	print M "<p>Datei: " . $rec->{pfad} . " seit " . $rec->{hinzu} . "</p>"; 
	foreach $gr (split(/,/, $rec->{groups})) {
		print M "<p>Festplatte: " . $GROUPS[$gr] . "</p>";
	}
	
	$ng = keys %{$indexGruppe{$rec->{gruppe}}};
	if ($ng > 6) {
		print M "<p><img src='../gruppe.png'> Es gibt insgesamt <b>" . $ng . "</b> Filme in der Gruppe <b>'<a href='../Gruppen/" . txt2url($rec->{gruppe}) . ".html'>" . $rec->{gruppe} . "</a>'</b></p>";
	} else {
		print M "<p><a href='../Gruppen/" . txt2url($rec->{gruppe}) . ".html'><img src='../gruppe.png' border='0'></a> Alle Filme aus Gruppe <b>'" . $rec->{gruppe} . "'</b></p><ul>";
		foreach $gnr (sort {lc($FILME{$a}->{titel}) cmp lc($FILME{$b}->{titel})} keys %{$indexGruppe{$rec->{gruppe}}}) {
			if ($FILME{$gnr}->{dreid}) {
				$dreid = "&nbsp;&nbsp;<a href='../Genres/3d.html'><img src='../3d.png' title='3-D Film' class='ddd' border='0'></a>";
			} else {
				$dreid = "";
			}
			if ($gnr eq $nr) {
				print M "<li><i>" . $FILME{$gnr}->{titel} . $dreid . " <small>(der aktuelle Film)</small></i></li>";
			} else {
				print M "<li><a href='../movies/$gnr.html'>" . $FILME{$gnr}->{titel} . "</a>" . $dreid . "</li>";
			}
		}
		print M "</ul>";
	}
	print M "</body></html>";
	close (M);
}


print F "</tbody>
  </table>
  <ul class='pagination'></ul>
</div><script>var options = {
  valueNames: [  'nr', 'titel', 'jahr', 'dauer', 'fsk', 'reso', 'imdb', 'meta', 'genre' ],
   plugins: [
      ListPagination({})
    ]
};
var userList = new List('dvd', options);
</script><p><small><a href='Genres/doppelt.html'>Filme ohne IMDB-Zuordnung und doppelte Filme</a></small></p><img id='imagehover' class='imagehover' src='' alt=''></body></html>";
close (F);

print L 'function rand (min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}
for (i = 0; i < 25; i++) { 
	document.write(MOVIES[rand(1, ' . $lucky . ')]);
}
</script></body></html>';
close (L);
close (C);

# Umkodierung, damit XLS das mit Umlauten auch alles kapiert
open (my $IN, "<:encoding(UTF-8)", "tabelle-utf8.csv") || die "Can't open tabelle-utf8.csv - $!\n";
open (my $OUT, ">:encoding(Windows-1252)", "tabelle.csv") || die "Can't open tabelle.csv - $!\n";
while (<$IN>) {
	print $OUT $_;
}
close (IN);
close (OUT);
open (my $IN, "<:encoding(UTF-8)", "gruppen-utf8.csv") || die "Can't open gruppen-utf8.csv - $!\n";
open (my $OUT, ">:encoding(Windows-1252)", "gruppen.csv") || die "Can't open gruppen.csv - $!\n";
while (<$IN>) {
	print $OUT $_;
}
close (IN);
close (OUT);
	
# Liste neuer Filme
$i = 0;
foreach $nr (sort {lc($FILME{$b}->{hinzusort}) cmp lc($FILME{$a}->{hinzusort})} keys %FILME) {
	if ($nr eq "count") { next; }
	if ($nr =~ m/HASH/) { next; }
	last if ($i++ == 150);
	$rec = $FILME{$nr};
	print N '<div class="neu"><a href="Movies/' . $nr . '.html" title="' . $rec->{beschreibung} . '"><img src="../Covers/' . $rec->{cover} . '" class="neu"><br clear=all>' . $rec->{ptitel} . '</a><br><small>Jahr: ' . $rec->{jahr} . '&nbsp;&nbsp;Dauer: ' . $rec->{dauer} . '<br>FSK: ' . $rec->{fsk} . '&nbsp;&nbsp;Aufl&ouml;sung: ' . $rec->{reso} . '<br>Genre: ' . $genreclear{substr($rec->{genre}, 0, 1)} . '&nbsp;&nbsp;IMDB: ' . $rec->{imdbwertung} . '/10</small></div>' . "\n";
	# Tabelle zum Vergleich
	# print F '<tr><td class="nr">' . $nr . ($rec->{gesehen} ? ' <span title="gesehen am ' . $rec->{gesehen} . '">&deg;&deg;</span>' : '') . '</td><td><a href="Movies/' . $nr . '.html"><span class="titel">' . $rec->{titel} . '</span></a>' . $dreid . '</td><td><a href="Jahr/' . $rec->{jahr} . '.html"><span class="jahr">' . $rec->{jahr} . '</span></a></td><td class="fsk"><a href="FSK/' . $rec->{fsk} . '.html">'. $rec->{fsk} . '</a></td><td><a href="Zeit/' . $rec->{zeit} . '.html" title="' . $zeitName{$rec->{zeit}} . '"><span class="dauer">' . $rec->{dauer} . '</span></a></td><td class="reso" title="' . $rec->{mb} . ' MB / ' . int(100 * $rec->{mb}/1024 + 0.5)/100 . ' GB">' . $rec->{reso} . '</td><td class="imdb" title="' . $rec->{anzahl_bewertungen} . ' Bewertungen">' . $rec->{imdbwertung} . ' / 10</td><td class="genre">' . $genreclear{substr($rec->{genre}, 0, 1)} . "</td></tr>\n";
}
print N "</div></body></html>";
close (N);