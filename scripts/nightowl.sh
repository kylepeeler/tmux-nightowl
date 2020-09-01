#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

main()
{
  # set current directory variable
  current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # set configuration option variables
  show_battery=$(get_tmux_option "@nightowl-show-battery" true)
  show_network=$(get_tmux_option "@nightowl-show-network" true)
  show_weather=$(get_tmux_option "@nightowl-show-weather" true)
  show_fahrenheit=$(get_tmux_option "@nightowl-show-fahrenheit" true)
  show_powerline=$(get_tmux_option "@nightowl-show-powerline" false)
  show_left_icon=$(get_tmux_option "@nightowl-show-left-icon" smiley)
  show_military=$(get_tmux_option "@nightowl-military-time" false)
  show_timezone=$(get_tmux_option "@nightowl-show-timezone" true)
  show_left_sep=$(get_tmux_option "@nightowl-show-left-sep" )
  show_right_sep=$(get_tmux_option "@nightowl-show-right-sep" )
  show_border_contrast=$(get_tmux_option "@nightowl-border-contrast" false)
  show_cpu_usage=$(get_tmux_option "@nightowl-cpu-usage" false)
  show_ram_usage=$(get_tmux_option "@nightowl-ram-usage" false)
  show_gpu_usage=$(get_tmux_option "@nightowl-gpu-usage" false)


  # Available Night Owl Colors:
  # #011627 Background
  # #d6deeb Foreground
  # #01111d Current Line
  # #1d3b53 Selection
  # #80a4c2 Cursor
  # #4b6479 Line Number
  # #c5e4fd Current Line Number
  # #7fdbca Tags/Keywords
  # #637777 Comment
  # #ef5350 Red
  # #22da6e Green
  # #addb67 Yellow
  # #82aaff Blue
  # #f78c6c Orange
  # #c792ea Magenta
  # #21c7a8 Cyan
  # #ffffff White
  # #575656 Bright Black

  # Night Owl Color Pallette
  white='#ffffff'
  gray='#4b6479'
  dark_gray='#011627'
  high_contrast_pane_border='#80a4c2'
  pane_border='#1d3b53'
  blue='#82aaff',
  cyan='#21c7a8'
  green='#22da6e'
  orange='#f78c6c'
  red='#ef5350'
  pink='#c792ea'
  yellow='#addb67'
  

  # Handle left icon configuration
  case $show_left_icon in
      smiley)
          left_icon="☺ ";;
      session)
          left_icon="#S ";;
      window)
	  left_icon="#W ";;
      *)
          left_icon=$show_left_icon;;
  esac

  # Handle powerline option
  if $show_powerline; then
      right_sep="$show_right_sep"
      left_sep="$show_left_sep"
  fi

  # start weather script in background
  if $show_weather; then
    $current_dir/sleep_weather.sh $show_fahrenheit &
  fi

  # Set timezone unless hidden by configuration
  case $show_timezone in
      false)
          timezone="";;
      true)
          timezone="#(date +%Z)";;
  esac

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval 5

  # set clock to 12 hour by default
  tmux set-option -g clock-mode-style 12

  # set length 
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # pane border styling
  if $show_border_contrast; then
    tmux set-option -g pane-active-border-style "fg=${high_contrast_pane_border}"
  else
    tmux set-option -g pane-active-border-style "fg=${pane_border}"
  fi
  tmux set-option -g pane-border-style "fg=${gray}"

  # message styling
  tmux set-option -g message-style "bg=${gray},fg=${white}"

  # status bar
  tmux set-option -g status-style "bg=${gray},fg=${white}"


  # Powerline Configuration
  if $show_powerline; then

      tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon} #[fg=${green},bg=${gray}]#{?client_prefix,#[fg=${yellow}],}${left_sep}"
      tmux set-option -g  status-right ""
      powerbg=${gray}

      if $show_battery; then # battery
        tmux set-option -g  status-right "#[fg=${pink},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${pink}] #($current_dir/battery.sh)"
        powerbg=${pink}
      fi

      if $show_ram_usage; then
	 tmux set-option -ga status-right "#[fg=${yellow},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${yellow}] #($current_dir/ram_info.sh)"
	 powerbg=${yellow}
      fi

      if $show_cpu_usage; then
	 tmux set-option -ga status-right "#[fg=${red},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${red}] #($current_dir/cpu_info.sh)"
	 powerbg=${red}
      fi

      if $show_gpu_usage; then
	 tmux set-option -ga status-right "#[fg=${cyan},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${cyan}] #($current_dir/gpu_usage.sh)"
	 powerbg=${cyan}
      fi	

      if $show_network; then # network
        tmux set-option -ga status-right "#[fg=${blue},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${blue}] #($current_dir/network.sh)"
        powerbg=${blue}
      fi

      if $show_weather; then # weather
        tmux set-option -ga status-right "#[fg=${orange},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${orange}] #(cat $current_dir/../data/weather.txt)"
        powerbg=${orange}
      fi

      if $show_military; then # military time
	tmux set-option -ga status-right "#[fg=${dark_purple},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${white},bg=${dark_purple}] %a %m/%d %R ${timezone} "
      else
	tmux set-option -ga status-right "#[fg=${dark_purple},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${white},bg=${dark_purple}] %a %m/%d %I:%M %p ${timezone} "
      fi

      tmux set-window-option -g window-status-current-format "#[fg=${gray},bg=${dark_purple}]${left_sep}#[fg=${white},bg=${dark_purple}] #I #W #[fg=${dark_purple},bg=${gray}]${left_sep}"
  
  # Non Powerline Configuration
  else
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"

    tmux set-option -g  status-right ""

      if $show_battery; then # battery
        tmux set-option -g  status-right "#[fg=${dark_gray},bg=${pink}] #($current_dir/battery.sh) "
      fi
      if $show_ram_usage; then
	tmux set-option -ga status-right "#[fg=${dark_gray},bg=${yellow}] #($current_dir/ram_info.sh) "
      fi

      if $show_cpu_usage; then
	tmux set-option -ga status-right "#[fg=${dark_gray},bg=${red}] #($current_dir/cpu_info.sh) "
      fi

      if $show_gpu_usage; then
	tmux set-option -ga status-right "#[fg=${dark_gray},bg=${cyan}] #($current_dir/gpu_usage.sh) "
      fi	

      if $show_network; then # network
        tmux set-option -ga status-right "#[fg=${dark_gray},bg=${blue}] #($current_dir/network.sh) "
      fi

      if $show_weather; then # weather
          tmux set-option -ga status-right "#[fg=${dark_gray},bg=${orange}] #(cat $current_dir/../data/weather.txt) "
      fi

      if $show_military; then # military time
	tmux set-option -ga status-right "#[fg=${white},bg=${dark_purple}] %a %m/%d %R ${timezone} "
      else
	tmux set-option -ga status-right "#[fg=${white},bg=${dark_purple}] %a %m/%d %I:%M %p ${timezone} "
      fi

      tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${dark_purple}] #I #W "

  fi
  
  tmux set-window-option -g window-status-format "#[fg=${white}]#[bg=${gray}] #I #W "
}

# run main function
main
