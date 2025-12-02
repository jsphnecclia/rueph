# Not entirely sure how this works be wary
# RUN FROM INSIDE RUEPH DIRECTORY

require "fileutils"

# SwissEph moved to Github
SWEPH_REPO = "https://github.com/aloistr/swisseph.git"
SWEPH_DIR  = "swisseph"

task default: %i[clean c_build get_ephe]

task :clean do
  FileUtils.rm_f  "src/libswe.so"
  FileUtils.rm_rf %w[src ephe swisseph doc]
end

task :c_build do
  sh "git clone --depth=1 #{SWEPH_REPO} #{SWEPH_DIR}" unless Dir.exist?(SWEPH_DIR)

  FileUtils.mkdir_p "src"

  # Build libswe.so in the root of the repo
  sh "make -C #{SWEPH_DIR} clean libswe.so"

  FileUtils.cp File.join(SWEPH_DIR, "libswe.so"), "src/libswe.so"
end

task :get_ephe do
  FileUtils.mkdir_p "ephe"

  # Copy only *files* from swisseph/ephe into our ephe/
  Dir.glob(File.join(SWEPH_DIR, "ephe", "**", "*")).each do |path|
    next unless File.file?(path)

    FileUtils.cp path, "ephe/"
  end
end

