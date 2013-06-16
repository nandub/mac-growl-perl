use strict;
use warnings;

use ExtUtils::MakeMaker;
use File::Spec::Functions;
use Getopt::Long;

my $opt = {};
GetOptions($opt, 'growl=s');

my $REQUIRED = '1.3.0';
my $GHA;

if ($opt->{growl}) {
	$GHA = $opt->{growl};
} elsif (-e '/Applications/Growl.app') {
	$GHA = '/Applications/Growl.app';
} else {
	$GHA = "$ENV{HOME}/Applications/Growl.app";
}

my $goodversion = checkversion();
warn "... but we will attempt to install anyway.\n" unless $goodversion;

WriteMakefile(
	NAME		=> 'Mac::Growl',
	VERSION_FROM	=> 'lib/Mac/Growl.pm',
	clean		=> {
		'FILES'		=> 'Mac-Growl-*'
	},
	NO_META		=> 1,
);

sub checkversion {
	my $info = catfile($GHA, "Contents", qw(Info.plist));

	my $fh;
	unless (open($fh, '<', $info)) {
		warn "warning: Growl cannot be found!\n";
		return;
	}

	my $version;
	while (<$fh>) {
		if ($version) {
			m|^\s*<string>([\d.]+)</string>\s*$|;
			$version = $1;
			last;
		} elsif (m|^\s*<key>CFBundleVersion</key>\s*$|) {
			$version = 1;
			next;
		}
	}

	if (! defined $version) {
		warn "warning: Growl version cannot be found!\n";
		return;
	}

	my($V, $R) = map { join '', map { chr } split /\./, $_ } ($version, $REQUIRED);
	if ($V lt $R) {
		warn "warning: Growl version is $version; minimum $REQUIRED required!\n";
		return;
	}

	return 1;
}
