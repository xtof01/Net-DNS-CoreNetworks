use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Net::DNS::CoreNetworks',
    VERSION_FROM    => 'lib/Net/DNS/CoreNetworks.pm',
    PREREQ_PM       => {
                     'HTTP::Tiny' => '0.042',
                     'JSON::MaybeXS' => '1.003005'
                   }
);
