project_name ?= m6809_buscard
target ?= xc95108-10-PC84
# Alternative target = xc95108-10-PC84

optimize ?= density
# alternative speed, density


lso:
	echo "work" > ${project_name}.lso

# Synthesis
synthesis:  ${project_name}.xst ${project_name}.lso
	if [ ! -d tmp ] ; then mkdir tmp ; fi
	xst -ifn ./${project_name}.xst -intstyle xflow -ofn ./${project_name}.syr


ngdbuild: ../src/${project_name}.ucf ${project_name}.ngc
	ngdbuild -dd _ngo -p ${target} -uc ../src/${project_name}.ucf ${project_name}.ngc  ${project_name}.ngd


# Fit the selected device and generate reports
cpldfit:  ${project_name}.ngd
	cpldfit -p ${target} \
	    -ofmt vhdl \
	    -optimize ${optimize} \
	    -loc on \
	    -slew fast \
	    -init low \
	    -inputs 18 \
	    -pterms 18 \
	    -power std \
	    -localfbk \
	    -pinfbk \
	    -exhaust ${project_name}.ngd

# Run the TA engine and generate reports
tsim:
	tsim ${project_name} ${project_name}.nga
	taengine -f ${project_name} -detail

# Generate the JEDEC file for programming
jedec:
	hprep6  -s IEEE1149 -n ${project_name} -i ${project_name}
	mv ${project_name}.jed ${project_name}_${target}.jed


# dump a verilog netlist
netgen:
	netgen -w -ofmt verilog  -aka ${project_name}.ngd

report: ${project_name}.rpt ${project_name}.syr
	egrep -i '(error|warning)' *.syr *.rpt

all: clean lso synthesis ngdbuild cpldfit tsim jedec netgen report

clean:
	rm -rf *~ .#*
	rm -rf  `ls -1 | egrep -v '(prj|\.xst|README|Makefile)'`
