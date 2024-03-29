#! /usr/bin/perl -wT

use strict;

$ENV{PATH}="/bin:/usr/bin";

my %results=('all' => "../popcon-mail/results", 'stable' => "../popcon-mail/results.stable");
my $popbase = "../www";
my %popcon= ('all' => "", 'stable' => "/stable");
my %popfile=('all' => "all-popcon-results.gz", 'stable' => "stable-popcon-results.gz");
my %poptext=('all' => "All reports", 'stable' => "Stable reports");
my $mirrorbase = "/srv/mirrors/debian";
my $docurlbase = "/";
my %popconver=("1.28" => "sarge", "1.41" => "etch", "1.46" => "lenny", "1.49" => "squeeze");
my %popver=();
my @dists=("main","contrib","non-free","non-US");
my @fields=("inst","vote","old","recent","no-files");
my %maint=();
my %list_header=(
"maint" => <<"EOF",
#<name> is the developer name;
#
#The fields below are the sum for all the packages maintained by that
#developer:
EOF
"source" => <<"EOF",
#<name> is the source package name;
#
#The fields below are the sum for all the binary packages generated by
#that source package:
EOF
"sourcemax" => <<"EOF");
#<name> is the source package name;
#
#The fields below are the maximum for all the binary packages generated by
#that source package:
EOF

# Progress indicator

sub mark
{
  print join(" ",$_[0],times),"\n";
}

# HTML templates

sub htmlheader
{
  print HTML <<"EOH";
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
  <html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <title> Debian Popularity Contest </title>
        <link rev="made" href="mailto:ballombe\@debian.org">
        <link rel="shortcut icon" href="/favicon.ico">
        </head>
        <body text="#000000" bgcolor="#FFFFFF" link="#0000FF" vlink="#800080" alink="#FF0000">
        <div align="center">
        <a href="http://www.debian.org/">
        <img src="http://www.debian.org/logos/openlogo-nd-50.png" border="0" hspace="0" vspace="0" alt="" width="50" height="61">
        </a>
        <a href="http://www.debian.org/">
        <img src="http://www.debian.org/Pics/debian.jpg" border="0" hspace="0" vspace="0" alt="Debian Project" width="179" height="61">
        </a>
        </div>
        <br>
        <table bgcolor="#DF0451" border="0" width="100%" cellpadding="0" cellspacing="0" summary="">
        <tr>
        <td valign="top">
        <img src="http://www.debian.org/Pics/red-upperleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
        </td>
        <td rowspan="2" align="center">
        <font color="#FFFF00"><big><big>Debian Popularity Contest</big></big></font>
        </td>
        <td valign="top">
        <img src="http://www.debian.org/Pics/red-upperright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
        </td>
        </tr>
        <tr>
        <td valign="bottom">
        <img src="http://www.debian.org/Pics/red-lowerleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
        </td>
        <td valign="bottom">
        <img src="http://www.debian.org/Pics/red-lowerright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
        </td>
        </tr>
        </table>
EOH
}

sub popconintro
{
  my ($name,$page) = @_;
  &htmlheader;
  print HTML <<"EOF";
  <p> <em> The popularity contest project is an attempt to map the usage of
  Debian packages.  This site publishes the statistics gathered from report
  sent by users of the <a
  href="http://packages.debian.org/popularity-contest">popularity-contest</a>
  package. This package sends every week the list of packages installed and the
  access time of relevant files to the server via email. Every day the server
  anonymizes the result and publishes this survey.
  For more information, read the <a href="${docurlbase}README">README</a> and the 
  <a href="${docurlbase}FAQ">FAQ</a>.
  </em> <p>
<form method="GET" action="http://qa.debian.org/popcon.php">Popcon statistics
for source package <input type="text" size="30" maxlength="80" name="package">
<input type="submit" value="Go">
</form> <p>

<style type="text/css">
  #tabs ul { padding: 0; margin: 0; background #DF0451; }
  #tabs li {
    display: inline;
    border: 2px #DF0451 solid;
    border-bottom-width: 0;
    margin: 0 2px 0 0;
    font-size: 140%;
    padding: 0 2px;
    -moz-border-radius: 15px 15px 0 0; border-radius: 15px 15px 0 0;
  }
  #tabs #current { background: #DF0451; color: #FFFF00; }
  #main { border: 2px #DF0451 solid; 
  -moz-border-radius: 0 15px 15px 15px; border-radius: 0 15px 15px 15px; }
</style>
<div id="tabs">
  <ul>
EOF
  for (keys %poptext)
  {
    if ($_ eq $name) {
      print HTML "<li id=\"current\">$poptext{$_}</li>\n";
    } else {
      print HTML "<li><a href=\"$popcon{$_}/$page\">$poptext{$_}</a></li>\n";
    }
  }
  print HTML <<"EOF";
  </ul>
</div>
<div id="main">
EOF
}

sub htmlfooter
{
  my ($numsub) = @_;
  my $date=gmtime();
  print HTML <<EOF;
<pre>
inst     : number of people who installed this package;
vote     : number of people who use this package regularly;
old      : number of people who installed, but don't use this package regularly;
recent   : number of people who upgraded this package recently;
no-files : number of people whose entry didn't contain enough information (atime
and ctime were 0).
</pre>
<p>
Number of submissions considered: $numsub
</p><p>
To participate in this survey, install the <a href="http://packages.debian.org/popularity-contest">popularity-contest</a> package.
</p>
EOF
  print HTML <<EOH
<p>
</div>
<small>
Made by <a href="mailto:ballombe\@debian.org"> Bill Allombert </a>. Last generated on $date UTC. <br>
<a href="http://popcon.alioth.debian.org" > Popularity-contest project </a> by Avery Pennarun, Bill Allombert and Petter Reinholdtsen.
<BR>
Copyright (C) 2004-2005 <A HREF="http://www.spi-inc.org/">SPI</A>;
See <A HREF="http://www.debian.org/license">license terms</A>.
</small>
</body>
</html>
EOH
}

# Report generators

sub make_sec
{
  my $sec="$_[0]/$_[1]";
  -d $sec || system("mkdir","-p","$sec");
}

sub print_by
{
   my ($dir,$f)=@_;
   print HTML ("<a href=\"$dir/by_$f\">$f</a> [<a href=\"$dir/by_$f.gz\">gz</a>] ");
}

sub make_by
{
  my ($popcon,$sec,$order,$pkg,$winner,$listp) = @_;
  my (%sum, $me);
  my @list = sort {$pkg->{$b}->{$order}<=> $pkg->{$a}->{$order} || $a cmp $b } @{$listp};
  $winner->{"$sec/$order"}=$list[0];
  open DAT , "|-:utf8", "tee $popcon/$sec/by_$order | gzip -c > $popcon/$sec/by_$order.gz";
  if (defined($list_header{$sec}))
  {
    print DAT $list_header{$sec};
    $me="";
  }
  else 
  {
    print DAT <<"EOF";
#Format
#   
#<name> is the package name;
EOF
    $me="(maintainer)";
  }
  print DAT << "EOF";
#<inst> is the number of people who installed this package;
#<vote> is the number of people who use this package regularly;
#<old> is the number of people who installed, but don't use this package
#      regularly;
#<recent> is the number of people who upgraded this package recently;
#<no-files> is the number of people whose entry didn't contain enough
#           information (atime and ctime were 0).
#rank name                            inst  vote   old recent no-files $me
EOF
  my $format="%-5d %-30s".(" %5d"x($#fields+1))." %-32s\n";
  my $rank=0;
  my $p;
  for $p (@list)
  {
    $rank++;
    my $m=(defined($list_header{$sec})?"":"($maint{$p})");
    printf  DAT $format, $rank, $p, (map {$pkg->{$p}->{$_}} @fields), $m;
    $sum{$_}+=$pkg->{$p}->{$_} for (@fields);
  }
  print  DAT '-'x66,"\n";
  printf DAT $format, $rank, "Total", map {defined($sum{$_})?$sum{$_}:0} @fields, "";
  close DAT;
}

sub make
{
  my ($popcon, $sec,$pkg,$winner,$list)=@_;
  make_sec ($popcon,$sec);
  make_by ($popcon, $sec, $_, $pkg, $winner, $list) for (@fields);
}
sub print_pkg
{
  my ($pkg)=@_;
  return unless (defined($pkg));
  my $size=length $pkg;
  my $pkgt=substr($pkg,0,20);
  print HTML "<a href=\"http://packages.debian.org/$pkg\">$pkgt</a> ",
  ' 'x(20-$size);
}

my %section=();
my %source=();

#Format
#<name> <vote> <old> <recent> <no-files>
#   
#<name> is the package name;
#<vote> is the number of people who use this package regularly;
#<old> is the number of people who installed, but don't use this package
#        regularly;
#<recent> is the number of people who upgraded this package recently;
#<no-files> is the number of people whose entry didn't contain enough
#        information (atime and ctime were 0).

sub read_result
{
  my ($name) = @_;
  my $results = $results{$name};
  my (%pkg,%maintpkg,%sourcepkg,%sourcemax,%arch,$numsub,%release);
  open PKG, "<:utf8","$results" or die "$results not found";
  while(<PKG>)
  {
    my ($type,@values)=split(" ");
    if ($type eq "Package:")
    {
          my @votes = @values;
          my $name = shift @votes;
          unshift @votes,$votes[0]+$votes[1]+$votes[2]+$votes[3];
            $section{$name}='unknown' unless (defined($section{$name}));
            $maint{$name}='Not in sid' unless (defined($maint{$name}));
            $source{$name}='Not in sid' unless (defined($source{$name}));
            for(my $i=0;$i<=$#fields;$i++)
            {
                    my ($f,$v)=($fields[$i],$votes[$i]);
                    $pkg{$name}->{$f}=$v;
                    $maintpkg{$maint{$name}}->{$f}+=$v;
                    $sourcepkg{$source{$name}}->{$f}+=$v;
                    my($sm)=$sourcemax{$source{$name}}->{$f};
                    $sourcemax{$source{$name}}->{$f}=$v 
                      if (!defined($sm) || $sm < $v);
            }
    }
    elsif ($type eq "Architecture:")
    {
      my ($a,$nb)=@values;
      $arch{$a}=$nb;
    }
    elsif ($type eq "Submissions:")
    {
      ($numsub)=@values;
    }
    elsif ($type eq "Release:")
    {
      my ($a,$nb)=@values;
      $release{$a}=$nb;
    }
  }
  close PKG;
  return {'name'      => $name,
          'pkg'       => \%pkg,
          'maintpkg'  => \%maintpkg,
          'sourcepkg' => \%sourcepkg,
          'sourcemax' => \%sourcemax,
          'arch'      => \%arch,
          'release'   => \%release,
          'numsub'    => $numsub};
}

sub gen_sections
{
  my ($stat) = @_;
  my $name = $stat->{'name'};
  my %pkg = %{$stat->{'pkg'}};
  my %maintpkg = %{$stat->{'maintpkg'}};
  my %sourcepkg = %{$stat->{'sourcepkg'}};
  my %sourcemax = %{$stat->{'sourcemax'}};
  my %arch = %{$stat->{'arch'}};
  my %release = %{$stat->{'release'}};
  my $numsub = $stat->{'numsub'};
  my $popcon = "$popbase$popcon{$name}";
  my $popfile = $popfile{$name};
  my @pkgs=sort keys %pkg;
  my %sections = map {$section{$_} => 1} keys %section;
  my @sections = sort keys %sections;
  my @maints= sort keys %maintpkg;
  my @sources= sort keys %sourcepkg;
  my %winner = ();
  my ($sec, $dir, $f);
  for $sec (@sections)
  {
    my @list = grep {$section{$_} eq $sec} @pkgs;
    make ($popcon, $sec, \%pkg, \%winner, \@list);
  }
  #There is a hack: '.' is both the current directory and
  #the catchall regexp.
  for $sec (".",@dists)
  {
    my @list = grep {$section{$_} =~ /^$sec/ } @pkgs;
    make ($popcon, $sec, \%pkg, \%winner, \@list);
  }
  make ($popcon, "maint", \%maintpkg, \%winner, \@maints);
  make ($popcon, "source", \%sourcepkg, \%winner, \@sources);
  make ($popcon, "sourcemax", \%sourcemax, \%winner, \@sources);

  for $sec (@dists)
  {
    open HTML , ">:utf8", "$popcon/$sec/index.html";
    opendir SEC,"$popcon/$sec";
    popconintro($name,"$sec/index.html");
    printf HTML ("<p>Statistics for the section %-16s sorted by fields: ",$sec);
    print_by (".",$_) for (@fields);
    print HTML ("\n </p> \n");
    printf HTML ("<p> <a href=\"first.html\"> First packages in subsections for each fields </a>\n");
    printf HTML ("<p>Statistics for subsections sorted by fields\n <pre>\n");
    for $dir (sort readdir SEC)
    {
      -d "$popcon/$sec/$dir" or next;
      $dir !~ /^\./ or next;
      printf HTML ("%-16s : ",$dir);
      print_by ($dir,$_) for (@fields);
      print HTML ("\n");
    }
    print HTML ("\n </pre>\n");
    htmlfooter $numsub;
    closedir SEC;
    close HTML;
  }
  for $sec (@dists)
  {
    open HTML , ">:utf8", "$popcon/$sec/first.html";
    opendir SEC,"$popcon/$sec";
    popconintro($name,"$sec/first.html");
    printf HTML ("<p>First package in section %-16s for fields: ",$sec);
    for $f (@fields)
    {
            print_pkg $winner{"$sec/$f"};
    }
    print HTML ("\n </p> \n");
    printf HTML ("<p> <a href=\"index.html\"> Statistics by subsections sorted by fields </a>\n");
    printf HTML ("<p>First package in subsections for fields\n <pre>\n");
    printf HTML ("%-16s : ","subsection");
    for $f (@fields)
    {
            printf HTML ("%-20s ",$f);
    }
    print HTML ("\n","_"x120,"\n");
    for $dir (sort readdir SEC)
    {
            -d "$popcon/$sec/$dir" or next;
            $dir !~ /^\./ or next;
            printf HTML ("%-16s : ",$dir);
            for $f (@fields)
            {
                    print_pkg $winner{"$sec/$dir/$f"};
            }
            print HTML ("\n");
    }
    print HTML ("\n </pre>\n");
    htmlfooter $numsub;
    closedir SEC;
    close HTML;
  }
  open HTML , ">:utf8", "$popcon/index.html";
  popconintro($name,"index.html");
  printf HTML ("<p>Statistics for the whole archive sorted by fields: <pre>");
  print_by (".",$_) for (@fields);
  print HTML ("</pre>\n </p> \n");
  printf HTML ("<p>Statistics by maintainers sorted by fields: <pre>");
  print_by ("maint",$_) for (@fields);
  print HTML ("</pre>\n </p> \n");
  printf HTML ("<p>Statistics by source packages (sum) sorted by fields: <pre>");
  print_by ("source",$_) for (@fields);
  print HTML ("</pre>\n </p> \n");
  printf HTML ("<p>Statistics by source packages (max) sorted by fields: <pre>");
  print_by ("sourcemax",$_) for (@fields);
  print HTML ("</pre>\n </p> \n");
  printf HTML ("<p>Statistics for sections sorted by fields\n <pre>\n");
  for $dir ("main","contrib","non-free","non-US","unknown")
  {
    -d "$popcon/$dir" or next;
    $dir !~ /^\./ or next;
    if ($dir eq "unknown")
    {
      printf HTML ("%-16s : ",$dir);
    }
    else
    {
      printf HTML ("<a href=\"$dir/index.html\">%-16s</a> : ",$dir);
    }
    print_by ($dir,$_) for (@fields);
    print HTML ("\n");
  }
  print HTML  <<'EOF';
</pre>
<table border="0" cellpadding="5" cellspacing="0" width="100%">
<tr>
<td>
Statistics per Debian architectures:
<pre>
EOF
    for $f (grep { $_ ne 'unknown' } sort keys %arch)
    {
      my ($port)=split('-',$f);
      $port="$port/";
      $port="kfreebsd-gnu/" if ($port eq "kfreebsd/");
      printf HTML "<a href=\"http://www.debian.org/ports/$port\">%-16s</a> : %-10s <a href=\"stat/sub-$f.png\">graph</a>\n",$f,$arch{$f};
    }
  if (defined $arch{"unknown"}) {
    printf HTML "%-16s : %-10s <a href=\"stat/sub-unknown.png\">graph</a>\n","unknown",$arch{"unknown"}
  }
  print HTML "</pre></td>\n";
  print HTML  <<'EOF';
<td>
<table>
  <tr><td>
    <img alt="Graph of number of submissions per architectures"
    width="600" height="400" src="stat/submission.png">
  </td></tr>
  <tr><td>
    <img alt="Graph of number of submissions per architectures (last 12 months)"
    width="600" height="400" src="stat/submission-1year.png">
  </td></tr>
</table>
</td>
EOF
  print HTML  <<'EOF';
</tr><tr><td>
Statistics per popularity-contest releases:
<pre>
EOF
    for $f (grep { $_ ne 'unknown' } sort keys %release)
    {
      my($name) = $f;
      $name = "$f ($popconver{$f})" if (defined($popconver{$f}));
      printf HTML "%-25s : %-10s \n",$name,$release{$f};
    }
  if (defined $release{"unknown"}) {
    printf HTML "%-25s : %-10s \n","unknown",$release{"unknown"};
  }
  print HTML "</pre></td>\n";
  print HTML  <<'EOF';
<td>
  <table>
    <tr><td>
      <img alt="Graph of popularity-contest versions in use"
       width="600" height="400" src="stat/release.png">
    </td></tr>
    <tr><td>
      <img alt="Graph of popularity-contest versions in use (12 last months)"
       width="600" height="400" src="stat/release-1year.png">
    </td></tr>
  </table>
</td>
EOF
  print HTML "</tr></table><p>\n";
  print HTML "<a href=\"$popfile\">Raw popularity-contest results</a>\n";
  htmlfooter $numsub;
  close HTML;
}

sub read_packages
{
  my ($file,$dist);
  for $file ("slink","slink-nonUS","potato","potato-nonUS",
      "woody","woody-nonUS","sarge","etch")
  {
    open AVAIL, "<:utf8", "$file.sections" or die "Cannot open $file.sections";
    while(<AVAIL>)
    {
      my ($p,$sec)=split(' ');
      defined($sec) or last;
      chomp $sec;
      $sec =~ m{^(non-US|contrib|non-free)/} or $sec="main/$sec";
      $section{$p}=$sec;
      $maint{$p}="Not in sid";
      $source{$p}="Not in sid";
    }
    close AVAIL;
  }
  mark "Reading legacy packages...";
  for $dist ("stable", "testing", "unstable")
  {
    for (glob("$mirrorbase/dists/$dist/*/binary-*/Packages.gz"))
    {
      /([^[:space:]]+)/ or die("incorrect package name");
      my $file = $1;#Untaint
        open AVAIL, "-|:encoding(UTF-8)","zcat $file";
      my $p;
      while(<AVAIL>)
      {
        /^Package: (.+)/  and do {$p=$1;$maint{$p}="bug";$source{$p}=$p;next;};
        /^Version: (.+)/ && $p eq "popularity-contest" 
          and do { $popver{$dist}=$1; next;};
        /^Maintainer: ([^()]+) (\(.+\) )*<.+>/
          and do { $maint{$p}=join(' ',map{ucfirst($_)} split(' ',lc $1));next;};
        /^Source: (\S+)/ and do { $source{$p}=$1;next;};
        /^Section: (.+)/ or next;
        my $sec = $1;
        $sec =~ m{^(non-US|contrib|non-free)/} or $sec="main/$sec";
        $section{$p}=$sec;
      }
      close AVAIL;
    }
  }
  mark "Reading current packages...";
  for $dist ("stable", "testing", "unstable")
  {
    my($v)=$popver{$dist};
    $popconver{$v}=defined($popconver{$v})?"$popconver{$v}/$dist":$dist;
  }
}

# Main code

read_packages();

mark "Reading packages...";

my %stat = ('all' => read_result('all'),
            'stable' => read_result('stable'));

mark "Reading stats...";

for (keys %stat)
{
  gen_sections($stat{$_});
}

mark "Building pages";
