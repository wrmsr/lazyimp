.PHONY: all
all: check test-all package-all

#

VENV?=13
VENVS=\
	14 \
	13 \
	12 \
	11 \

.PHONY: test-all
test-all:
	for VENV in ${VENVS} ; do \
		VENV="$$VENV" ${MAKE} test || exit 1 ; \
	done

.PHONY: package-all
package-all:
	for VENV in ${VENVS} ; do \
		VENV="$$VENV" ${MAKE} package || exit 1 ; \
	done

#

.PHONY: clean
clean:
	rm -rf \
		.mypy_cache \
		.venvs \
		\
		*.egg-info \
		build \
		dist \
		\
		lazyimp/*.so \

#

PYTHON:=".venvs/${VENV}/bin/python"

.PHONY: venv
venv:
	@if [ -z "${VENV}" ] ; then \
		echo 'Must set VENV' >&2 && \
		exit 1 ; \
	fi

	@mkdir -p .venvs

	@if [ ! -d ".venvs/${VENV}" ] ; then \
		if command -v om >/dev/null ; then \
			$$(om interp resolve "3.${VENV}") -m venv ".venvs/${VENV}" ; \
		else \
			uv venv ".venvs/${VENV}" --python "3.${VENV}" ; \
		fi && \
		\
		${PYTHON} -m ensurepip && \
		${PYTHON} -m pip install --upgrade setuptools build ; \
	fi

.PHONY: build
build: venv
	${PYTHON} setup.py build_ext --inplace

.PHONY: test
test: build
	${PYTHON} -m unittest lazyimp.tests.test_lazyimp

.PHONY: package
package: venv
	${PYTHON} -m build .

#

.PHONY: check
check: venv
	@if ! ${PYTHON} -c 'import mypy' 2>/dev/null ; then \
		${PYTHON} -m pip install mypy ; \
	fi

	${PYTHON} -m mypy lazyimp
