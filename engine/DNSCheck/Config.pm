#!/usr/bin/perl
#
# $Id$
#
# Copyright (c) 2007 .SE (The Internet Infrastructure Foundation).
#                    All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
######################################################################
package DNSCheck::Config;

use 5.8.0;
use strict;
use warnings;

use Config;
use File::Spec::Functions;
use YAML 'LoadFile';

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    bless $self, $proto;

    my %arg = @_;

    my $configdir = catfile($Config{'installprefix'}, 'share/dnscheck');
    $configdir = $arg{'configdir'} if defined($arg{'configdir'});

    my $sitedir = $configdir;
    $sitedir = $arg{'sitedir'} if defined($arg{'sitedir'});

    my $configfile = catfile($configdir, 'config.yaml');
    $configfile = $arg{'configfile'} if defined($arg{'configfile'});

    my $policyfile = catfile($configdir, 'policy.yaml');
    $policyfile = $arg{'policyfile'} if defined($arg{'policyfile'});

    my $siteconfigfile = catfile($configdir, 'site_config.yaml');
    $siteconfigfile = $arg{'siteconfigfile'} if defined($arg{'siteconfigfile'});

    my $sitepolicyfile = catfile($configdir, 'site_policy.yaml');
    $sitepolicyfile = $arg{'sitepolicyfile'} if defined($arg{'sitepolicyfile'});

    $self->{'configdir'}      = $configdir;
    $self->{'sitedir'}        = $sitedir;
    $self->{'configfile'}     = $configfile;
    $self->{'policyfile'}     = $policyfile;
    $self->{'siteconfigfile'} = $siteconfigfile;
    $self->{'sitepolicyfile'} = $sitepolicyfile;

    my $cfdata  = LoadFile($configfile)     if -r $configfile;
    my $pfdata  = LoadFile($policyfile)     if -r $policyfile;
    my $scfdata = LoadFile($siteconfigfile) if -r $siteconfigfile;
    my $spfdata = LoadFile($sitepolicyfile) if -r $sitepolicyfile;

    _hashrefcopy($self, $cfdata)  if defined($cfdata);
    _hashrefcopy($self, $scfdata) if defined($scfdata);
    _hashrefcopy($self, $pfdata)  if defined($pfdata);
    _hashrefcopy($self, $spfdata) if defined($pfdata);

    return $self;
}

###
### Non-public functions below here
###

sub _hashrefcopy {
    my ($target, $source) = @_;

    foreach my $pkey (keys %{$source}) {
        $target->{$pkey} = {} unless defined($target->{$pkey});

        # Hash slice assignment to copy all keys under the $pkey top-level key
        @{ $target->{$pkey} }{ keys %{ $source->{$pkey} } } =
          values %{ $source->{$pkey} };
    }
}

1;

=head1 NAME

DNSCheck::Config - Read config files and make their contents available to
other modules.

=head1 DESCRIPTION

Reads any config files, specified and/or default ones, stores their contents
and provides methods that other modules can use to fetch them.

There are two distinct classes of configuration information, that reside in
separate files. There is I<configuration>, which modifies how things run. This
is, for example, network timeouts, database connection information, file paths
and such. In addition to this there is I<policy>, which specifies things about
the tests that get run. Most importantly, the policy information specifies the
reported severity level of various test failures.

By default, C<DNSCheck::Config> will look for configuration and policy files
in the directory C<share/dnscheck> under the Perl installation root. This is
where C<make install> will put the default files. Also by default, it will
look for four different files: F<policy.yaml>, F<config.yaml>,
F<site_policy.yaml> and F<site_config.yaml>. Only the first two exist by
default. If the second two exist, they will override values in their
respective non-site file. Local changes should go in the site files, since
the default files will get overwritten when a new DNSCheck version is
installed.

There is no protection against having the same keys in the configuration and
policy files. The configuration/policy distinction is entirely for human use,
and if they want to put everything in the same bucket they're perfectly
welcome to do so.

=head1 METHODS

=over

=item ->new()

The C<new> method creates a new C<DNSCheck::Config> object. It takes named
parameters in the perl/Tk style (but without the initial dashes). 

The available parameters are these:

=over

=item configdir

The path to the directory in which the module should look for configuration
and policy files.

=item sitedir

The path to the directory where the site configuration files are. By default the same as F<configdir>.

=item configfile

The full path to the configuration file.

=item siteconfigfile

The full path to the site configuration file.

=item policyfile

The full path to the policy file.

=item sitepolicyfile

The full path to the site policy file.

=back

=back

=cut
