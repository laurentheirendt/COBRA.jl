echo "ARCH = $ARCH"
echo "JULIA_VER = $JULIA_VER"

if [ "$ARCH" == "Linux" ]; then
    if [ "$JULIA_VER" == "v0.6.3" ]; then
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia -e 'println(versioninfo()); exit()'

        # temporary addition for julia 0.6 until new version of MAT tagged
        #/mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'Pkg.add("MAT"); Pkg.checkout("MAT")'

        # add the COBRA module
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'Pkg.clone(pwd())'
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'Pkg.build()'
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'Pkg.test("COBRA",coverage=true)'
    elif [ "$JULIA_VER" == "v0.7.0" ]; then
        # temporary addition for julia 0.6 until new version of MAT tagged
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.add("MAT"); Pkg.checkout("MAT")'

        # add the COBRA module
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.clone(pwd())'
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.build()'
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.test("COBRA",coverage=true)'
    fi
fi

CODE=$?
exit $CODE

# remove th julia directory to clean the installation directory
rm -rf ~/.julia