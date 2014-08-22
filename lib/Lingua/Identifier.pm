package Lingua::Identifier;

use 5.014004;
use strict;
use warnings FATAL => 'all';

use File::ShareDir 'dist_dir';
use File::Spec::Functions;

use Math::Matrix::MaybeGSL;

use Lingua::Identifier::ForwardProp;
use Lingua::Identifier::Feature::Trigrams;
use Lingua::Identifier::Feature::Alphabet;

=encoding UTF-8

=head1 NAME

Lingua::Identifier - A NN based approach for language identification

=head1 VERSION

Version 0.01_2

=cut

our $VERSION = '0.01_2';

our $sharedir = dist_dir('Lingua-Identifier');

our $features = do( catfile($sharedir, "features.dmp"));
die __PACKAGE__ . "- could not load 'features.dmp'" unless defined $features;

our $classes = do( catfile($sharedir, "classes.dmp"));
die __PACKAGE__ . "- could not load 'classes.dmp'" unless defined $classes;

our $thetas;
_load_thetas($sharedir);


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Lingua::Identifier;

    my $foo = Lingua::Identifier->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub _infer_language {
    my $file = shift;

    my $ngrams = _compute_features($file);

    my $data = Matrix->new(scalar(@$features), 1);

    my $i = 1;
    for my $feature (@$features) {
        if (exists($ngrams->{$feature})) {
            $data->assign($i, 1, $ngrams->{$feature});
        }
        $i++;
    }

    my $ans = Lingua::Identifier::ForwardProp::forward_prop($data, $thetas);

    my ($max, $pos) = $ans->max();

    if (wantarray) {
        my $prob_classes = {};
        my $i = 1;
        for (@$classes) {
            $prob_classes->{$_} = $ans->element($i++, 1);
        }
        return (%$prob_classes);
    } else {
        return $classes->[$pos-1];
    }
}

sub _load_file {    ## XXXX - later might be useful to accept encoding
    my $file = shift;
    my $str = "";
    open my $fh, "<:utf8", $file or die "Can not open file $file for reading: $!";
    while (<$fh>) {
        $str .= $_;
    }
    close $fh;

    return $str;
}

sub _load_thetas {
    my $path = shift;

    my $dir;

    opendir $dir, $path;
    my @ts = readdir $dir;

    for my $tfile (@ts) {
        if ($tfile =~ /theta-(\d+)\.dat/) {
            $thetas->[$1 - 1] = Matrix->read(catfile($path, $tfile));
        }
    }
}

sub _compute_features {
    my $str = shift;

    my $alphabets = Lingua::Identifier::Feature::Alphabet::features($str);
    my $trigrams  = Lingua::Identifier::Feature::Trigrams::features($str);

    return { %$trigrams, %$alphabets };
}

=head1 AUTHOR

Alberto Simões, C<< <ambs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lingua-Identifier at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lingua-Identifier>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Lingua::Identifier


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-Identifier>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Lingua-Identifier>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Lingua-Identifier>

=item * Search CPAN

L<http://search.cpan.org/dist/Lingua-Identifier/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Alberto Simões.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Lingua::Identifier
