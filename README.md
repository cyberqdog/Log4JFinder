# Log4JFinder
A tool to create an inventory of Java libraries/versions found on a system, outputs a CSV which can be fed to your indexers.

Usage: ./jarfinder.sh [-c] [-i IP override for output csv] [-h hostname override for csv output] -s <start directory>
  
       Use -c Include jar file contents in report
  
       Start directory must be set using the -s argument.
