which deactivate && source deactivate

export EARTHIO_BUILD_DIR=`pwd -P`
export EARTHIO_CHANNEL_STR="${EARTHIO_CHANNEL_STR:- -c elm -c elm/label/dev -c ioam -c conda-forge -c scitools/label/dev }"
export EARTHIO_TEST_ENV="${EARTHIO_TEST_ENV:-earth-env-test}"
export EARTHIO_INSTALL_METHOD="${EARTHIO_INSTALL_METHOD:-conda}"
export ELM_EXAMPLE_DATA_PATH="${ELM_EXAMPLE_DATA_PATH:-${EARTHIO_BUILD_DIR}/../elm-data}";
export PYTHON=${PYTHON:-3.5}
export NUMPY=${NUMPY:-1.11}
export ANACONDA_UPLOAD_USER="${ANACONDA_UPLOAD_USER:-elm}"

if [ -n "$MAKE_MINICONDA" ]; then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -f -p $HOME/miniconda
    export PATH="$HOME/miniconda/bin:$PATH"
fi

conda config --set always_yes true
conda install --name root 'conda-build<=3'
conda env remove --name ${EARTHIO_TEST_ENV} &> /dev/null

conda env create -n ${EARTHIO_TEST_ENV} -f environment.yml
source activate ${EARTHIO_TEST_ENV}
if [ "$EARTHIO_INSTALL_METHOD" = "git" ]; then
    python setup.py develop --no-deps
else
    conda build $EARTHIO_CHANNEL_STR --python $PYTHON --numpy $NUMPY conda.recipe
fi

if [ -z "$IGNORE_ELM_DATA_DOWNLOAD" ]; then
    mkdir -p $ELM_EXAMPLE_DATA_PATH
    pushd $ELM_EXAMPLE_DATA_PATH && python "$EARTHIO_BUILD_DIR/scripts/download_test_data.py" --files hdf4.tar.bz2 tif.tar.bz2 && popd
fi

source activate ${EARTHIO_TEST_ENV} && echo OK
