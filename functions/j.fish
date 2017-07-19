# Display general usage
function __j_usage
  echo 'Usage:'
  echo ' j <bookmark>               # Go to <bookmark>'
  echo ' j add [<bookmark>]         # Create a new bookmark with name <bookmark>'
  echo '                            # that points to the current directory.'
  echo '                            # If no <bookmark> is given,'
  echo '                            # the current directory name is used.'
  echo ' j rm <bookmark>            # Remove <bookmark>'
  echo ' j (ls|list)                # List all bookmarks'
  echo ' j (mv|rename) <old> <new>  # Change the name of a bookmark'
  echo '                            # from <old> to <new>'
  echo ' j help                     # Show this message'
  return 1
end

function __j_update_bookmark_completions
  set -l jfishdir ~/.jfish
  if test -d "$jfishdir"
    for b in (/bin/ls -a1 $jfishdir | grep -xv '.' | grep -xv '..')
      complete -c j -f -a "$b" -d 'Bookmark'
    end
  end
end

function j -d 'Bookmarking system.'
  set -l jfishdir ~/.jfish

  # Create jfish directory
  if not test -d "$jfishdir"
    if mkdir "$jfishdir"
      echo "Created bookmark directory '$jfishdir'."
    else
      echo "Failed to Create bookmark directory '$jfishdir'."
      return 1
    end
  end

  if test (count $argv) -lt 1
    __j_usage
    return 1
  end

  # Catch usage errors
  switch $argv[1]
    case rm
      if not test (count $argv) -ge 2
        echo "Usage: j $argv[1] BOOKMARK"
        return 1
      end

    case mv rename
      if not test (count $argv) -ge 3
        echo "Usage: j $argv[1] SOURCE DEST"
        return 1
      end
  end

  switch $argv[1]
    case add # Add a bookmark
      if test (count $argv) -eq 1
        set bookmarkname (basename (pwd))
      else
        set bookmarkname $argv[2]
      end

      if test -h "$jfishdir/$bookmarkname"
        echo "Error: The bookmark '$bookmarkname' already exists."
        echo "Use `j rm '$bookmarkname'` to remove it first."
        return 1
      else
        ln -s (pwd) "$jfishdir/$bookmarkname"
      end

      echo "Added bookmark '$bookmarkname'."
      __j_update_bookmark_completions

    case rm # Remove a bookmark
      if rm -f "$jfishdir/$argv[2]"
        echo "Removed bookmark '$argv[2]'."
        complete -e -c j -f -a "$argv[2]" -d 'Bookmark'
        __j_update_bookmark_completions
      else
        echo "The bookmark '$argv[2]' does not exist."
        return 1
      end

    case ls list # List all bookmarks
      for b in (/bin/ls -a1 $jfishdir)
        if test "$b" != '.' -a "$b" != '..'
          set -l dest (readlink "$jfishdir/$b")
          echo "$b -> $dest"
        end
      end

    case mv rename # Rename a bookmark
      if not test -h "$jfishdir/$argv[2]"
        echo "The bookmark '$argv[2]' does not exist."
        return 1
      else if test -h "$jfishdir/$argv[3]"
        echo "Error: The destination bookmark '$argv[3]' already exists."
        echo "Use `j rm '$argv[3]'` to remove it first."
        return 1
      end

      mv "$jfishdir/$argv[2]" "$jfishdir/$argv[3]"
      complete -e -c j -f -a "$argv[2]" -d 'Bookmark'
      __j_update_bookmark_completions

    case help
      __j_usage
      return 0

    case '*'
      if test -h "$jfishdir/$argv[1]"
        echo "cd (readlink \"$jfishdir/$argv[1]\")" | source -
      else
        echo "The bookmark '$argv[1]' does not exist."
        return 1
      end
  end
end
