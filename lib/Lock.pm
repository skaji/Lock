package Lock;
use 5.008001;
use strict;
use warnings;
use Fcntl qw(:flock);
use Carp 'croak';

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
    my ($self, $kind, $cb) = @_;
    $self->_reopen if $self->{pid} != $$;
    my $fh = $self->{fh};
    flock $fh, $kind or croak "flock $self->{file}: $!";
    Lock::Guard->new(sub { flock $fh, LOCK_UN });
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

    {
        my $guard = $lock->shared;
        print "do something with shared lock\n";
    }

    {
        my $guard = $lock->exclusive;
        print "do something with exclusive lock\n";
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

