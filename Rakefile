require "rake/testtask"

task :default => [:clean, :c_build, :get_ephe]

task :clean do
  `rm src/libswe.so`
  `rm -rf src`
  `rm -rf doc`
  `rm -rf ephe`
end

task :c_build do
  `wget https://www.astro.com/ftp/swisseph/swe_unix_src_2.10.02.tar.gz`
  `tar xvf swe_unix_src_2.10.02.tar.gz`
  `cd src && make libswe.so`
  `rm swe_unix_src_2.10.02.tar.gz`
end

task :get_ephe do
  `mkdir ephe`
  `wget -P ephe https://www.astro.com/ftp/swisseph/ephe/seas_12.se1`
  `wget -P ephe https://www.astro.com/ftp/swisseph/ephe/seas_18.se1`
  `wget -P ephe https://www.astro.com/ftp/swisseph/ephe/sefstars.txt`
  `wget -P ephe https://www.astro.com/ftp/swisseph/ephe/semo_12.se1`
  `wget -P ephe https://www.astro.com/ftp/swisseph/ephe/semo_18.se1`
  `wget -P ephe https://www.astro.com/ftp/swisseph/ephe/sepl_12.se1`
  `wget -P ephe https://www.astro.com/ftp/swisseph/ephe/sepl_18.se1`
end
