#
#  FACT(S):     aix_sysdumpdev
#
#  PURPOSE:     This custom fact returns a hash of "sysdumpdev -l" and
#		"sysdumpdev -e" data in name->value pairs.
#
#  RETURNS:     (hash)
#
#  AUTHOR:      Chris Petersen, Crystallized Software
#
#  DATE:        April 10, 2023
#
#  NOTES:       Myriad names and acronyms are trademarked or copyrighted by IBM
#               including but not limited to IBM, PowerHA, AIX, RSCT (Reliable,
#               Scalable Cluster Technology), and CAA (Cluster-Aware AIX).  All
#               rights to such names and acronyms belong with their owner.
#
#		NEVER FORGET!  "\n" and '\n' are not the same in Ruby!
#
#-------------------------------------------------------------------------------
#
#  LAST MOD:    (never)
#
#  MODIFICATION HISTORY:
#
#       (none)
#
#-------------------------------------------------------------------------------
#
Facter.add(:aix_sysdumpdev) do
    #  This only applies to the AIX operating system
    confine :osfamily => 'AIX'

    #  Define an empty hash to return
    l_aixSysdumpdev = {}

    #  Do the work
    setcode do
        #  Run the first command to look at general settings
        l_lines = Facter::Util::Resolution.exec('/usr/bin/sysdumpdev -l 2>/dev/null')

        #  Loop over the lines that were returned
        l_lines && l_lines.split("\n").each do |l_oneLine|
            #  Strip leading and trailing whitespace and split on any whitespace
            l_list = l_oneLine.strip().split()

            #  if...then ladder to deal with each value
            if (l_list[0] == 'primary')
                l_aixSysdumpdev[l_list[0].strip()] = l_list[1].strip()
            else
                if (l_list[0] == 'secondary')
                    l_aixSysdumpdev[l_list[0].strip()] = l_list[1].strip()
                else
                    if (l_list[0] == 'copy')
                        l_aixSysdumpdev[l_list.slice(0..1).join(' ')] = l_list.slice(2..-1).join(' ')
                    else
                        if (l_list[0] == 'forced')
                            l_aixSysdumpdev[l_list.slice(0..2).join(' ')] = l_list.slice(3..-1).join(' ')
                        else
                            if (l_list[0] == 'always')
                                l_aixSysdumpdev[l_list.slice(0..2).join(' ')] = l_list.slice(3..-1).join(' ')
                            else
                                if (l_list[0] == 'dump')
                                    l_aixSysdumpdev[l_list.slice(0..1).join(' ')] = l_list.slice(2..-1).join(' ')
                                else
                                    if (l_list[0] == 'type')
                                        l_aixSysdumpdev[l_list.slice(0..2).join(' ')] = l_list.slice(3..-1).join(' ')
                                    else
                                        if (l_list[0] == 'full')
                                            l_aixSysdumpdev[l_list.slice(0..2).join(' ')] = l_list.slice(3..-1).join(' ')
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        #  Run the second command to get estimated space
        l_lines = Facter::Util::Resolution.exec('/usr/bin/sysdumpdev -e 2>/dev/null')

        #  Loop over the lines that were returned
        l_lines && l_lines.split("\n").each do |l_oneLine|
            #  Strip leading and trailing whitespace and split on any whitespace
            l_list = l_oneLine.strip().split()

            #  if...then ladder to deal with each value
            if (l_list[0] == 'Estimated')
                l_aixSysdumpdev['estimated bytes'] = Integer(l_list[5].strip())
            end
        end

        #  Implicitly return the contents of the variable
        l_aixSysdumpdev
    end
end
