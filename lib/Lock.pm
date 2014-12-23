package Lock;
use 5.008001;
use strict;
use warnings;
use Fcntl qw(:flock);
use Carp 'croak';
use Sys::SigAction qw(timeout_call);
use Errno ();

our $VERSION = "0.01";

{
    package Lock::Guard;
    sub new { bless $_[1], $_[0] }
    sub DESTROY { $_[0]->() }
}

sub new {
    my ($class, $file) = @_;
    my $self = bless { file => $file }, $class;
    $self->_reopen;
    $self;
}

sub _reopen {
    my $self = shift;
    delete $self->{fh}; # just delete, don't close!
    open my $fh, ">>", $self->{file} or croak "open $self->{file}: $!";
    $self->{fh} = $fh;
    $self->{pid} = $$;
}

sub _lock {
    my ($self, $kind, $timeout_second) = @_;
    $self->_reopen if $self->{pid} != $$;
    my $fh = $self->{fh};

    if ($timeout_second) {
        my $is_timeout = timeout_call $timeout_second, sub {
            flock $fh, $kind or croak "flock $self->{file}: $!";
        };
        return if $is_timeout;
    } elsif (defined $timeout_second) {
        my $ok = flock $fh, $kind | LOCK_NB;
        if (!$ok) {
            if ($! == Errno::EWOULDBLOCK) {
                return;
            } else {
                croak "flock $self->{file}: $!";
            }
        }
    } else {
        flock $fh, $kind or croak "flock $self->{file}: $!";
    }

    Lock::Guard->new(sub { flock $fh, LOCK_UN });
}

sub exclusive {
    my ($self, $timeout_second) = @_;
    $self->_lock(LOCK_EX, $timeout_second);
}

sub shared {
    my ($self, $timeout_second) = @_;
    $self->_lock(LOCK_SH, $timeout_second);
}

1;
__END__

=encoding utf-8

=head1 NAME

Lock - do something with file lock

=head1 SYNOPSIS

    use Lock;

    my $lock = Lock->new(".lock");

    {
        my $guard = $lock->shared;
        print "do something with shared lock\n";
    }
    {
        my $guard = $lock->exclusive;
        print "do something with exclusive lock\n";
    }
    {
        # with timeout 5sec
        my $guard = $lock->shared(5) or die "timeout!";
        print "do something with shared lock\n";
    }
    {
        # with timeout 0sec, i.e. non blocking
        my $guard = $lock->shared(0) or last;
        print "do something with shared lock\n";
    }

=head1 DESCRIPTION

Lock is ...

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

