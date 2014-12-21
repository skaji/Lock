# NAME

Lock - do something with file lock

# SYNOPSIS

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

# DESCRIPTION

Lock is ...

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
