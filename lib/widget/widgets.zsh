# Modify the buffer and get a new suggestion
_zsh_autosuggest_widget_modify() {
	local suggestion

	# Invoke the original modification widget
	zle $(_zsh_autosuggest_original_widget $WIDGET) $@

	# Get a new suggestion if the buffer is not empty after modification
	if [ $#BUFFER -gt 0 ]; then
		suggestion=$(_zsh_autosuggest_get_suggestion $BUFFER)
	fi

	# Add the suggestion to the POSTDISPLAY
	if [ -n "$suggestion" ]; then
		POSTDISPLAY=${suggestion#$BUFFER}
	else
		unset POSTDISPLAY
	fi

	# Run highlight on new zle content
	_zsh_autosuggest_highlight
}

# Clear the suggestion
_zsh_autosuggest_widget_clear() {
	# Remove the suggestion
	unset POSTDISPLAY

	# Invoke the original widget
	zle $(_zsh_autosuggest_original_widget $WIDGET) $@

	# Run highlight on new zle content to clear highlight
	_zsh_autosuggest_highlight
}

# Accept the entire suggestion
_zsh_autosuggest_widget_accept() {
	# Only accept if the cursor is at the end of the buffer
	if [ $CURSOR -eq $#BUFFER ]; then
		# Add the suggestion to the buffer
		BUFFER="$BUFFER$POSTDISPLAY"

		# Remove the suggestion
		unset POSTDISPLAY

		# Move the cursor to the end of the buffer
		CURSOR=${#BUFFER}

		# Run highlight on new zle content
		_zsh_autosuggest_highlight
	else
		# If not at the end of the buffer, just invoke original widget
		zle $(_zsh_autosuggest_original_widget $WIDGET) $@
	fi
}

# Partially accept the suggestion
_zsh_autosuggest_widget_partial_accept() {
	# Temporarily accept the suggestion.
	BUFFER="$BUFFER$POSTDISPLAY"

	# Invoke the original widget to move the cursor
	zle $(_zsh_autosuggest_original_widget $WIDGET) $@

	# Set POSTDISPLAY to text right of the cursor
	POSTDISPLAY=$RBUFFER

	# Clip the buffer at the cursor
	BUFFER=$LBUFFER

	# Run highlight on new zle content
	_zsh_autosuggest_highlight
}

# Create the widgets
zle -N _zsh_autosuggest_widget_modify
zle -N _zsh_autosuggest_widget_clear
zle -N _zsh_autosuggest_widget_accept
zle -N _zsh_autosuggest_widget_partial_accept
