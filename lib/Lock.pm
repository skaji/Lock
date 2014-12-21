package Lock;
use 5.008001;
use strict;
use warnings;
use Fcntl qw(:flock);
use Carp 'croak';

our $VERSION = "0.01";

sub new {
    my ($class, $file) = @_;
    open my $fh, ">>", $file or croak "open $file: $!";
    bless { fh => $fh, file => $file, pid => $$ }, $class;
}

sub _reopen {
    my $self = shift;
    {
        my $fh = $self->{fh};
        close $fh;
        undef $fh;
    }
    open my $fh, ">>", $self->{file} or croak "open $self->{file}: $!";
    $self->{fh} = $fh;
}

sub _lock {
    my ($self, $kind, $cb) = @_;
    $self->_reopen if $self->{pid} != $$;
    my $wantarray = wantarray;
    my @return;
    my $fh = $self->{fh};
    flock $fh, $kind or croak "flock $self->{file}: $!";
    local $@;
    if ($wantarray) {
        @return = eval { $cb->() };
    } else {
        $return[0] = eval { $cb->() };
    }
    flock $fh, LOCK_UN;
    die "$@\n" if $@;
    $wantarray ? @return : $return[0];
}

sub exclusive {
    my ($self, $cb) = @_;
    $self->_lock(LOCK_EX, $cb);
}

sub shared {
    my ($self, $cb) = @_;
    $self->_lock(LOCK_SH, $cb);
}

1;
__END__

=encoding utf-8

=head1 NAME

Lock - do something with file lock

=head1 SYNOPSIS

    use Lock;

    my $lock = Lock->new(".lock");

    $lock->shared(sub {
        print "do something with shared lock\n";
    });

    $lock->exclusive(sub {
        print "do something with exclusive lock\n";
    });

=head1 DESCRIPTION

Lock is ...

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

