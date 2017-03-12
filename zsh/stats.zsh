
timer() {
    ## Set a timer to display duration ##
    # Usage:  timer [start|stop]
    Tcmd=$1
    case $Tcmd in
        start|Start|START) _StartSecs=$(date +%s)
            ;;
        stop|Stop|STOP) _StopSecs=$(date +%s)
                [[ ! $_StartSecs ]] && echo "[Internal Error] $FUNCNAME did not record a start." && return
                _DiffSecs=$(($_StopSecs-$_StartSecs))
                TimeLapse=$(date -u -d@"$_DiffSecs" +'%-Hh%-Mm%-Ss')
                echo "Timer: $TimeLapse"
            ;;
        *) echo "[Internal Error] $FUNCNAME: Unknown arg '$Tcmd'"
            ;;
    esac
}
