VENVS=\
	14 \
	13 \
	12 \
	11

.PHONY: all
all:
	for VENV in ${VENVS} ; do \
		VENV="$$VENV" ${MAKE} test || exit 1 ; \
	done

	for VENV in ${VENVS} ; do \
		VENV="$$VENV" ${MAKE} package || exit 1 ; \
	done

#

.PHONY: clean
clean:
	rm -rf \
		.venv \
		.venvs \
		\
		*.egg-info \
		build \
		dist \
		\
		lazyimp/*.so \

.PHONY: venv
venv:
	@if [ -z "${VENV}" ] ; then \
		echo 'Must set VENV' >&2 && \
		exit 1 ; \
	fi

	@mkdir -p .venvs

	@if [ ! -d ".venvs/${VENV}" ] ; then \
		if command -v om ; then \
			$$(om interp resolve "3.${VENV}") -m venv ".venvs/${VENV}" ; \
		else \
			uv venv ".venvs/${VENV}" --python "3.${VENV}" ; \
		fi && \
		\
		".venvs/${VENV}/bin/python" -m ensurepip && \
		".venvs/${VENV}/bin/python" -m pip install --upgrade setuptools build ; \
	fi

.PHONY: build
build: venv
	".venvs/${VENV}/bin/python" setup.py build_ext --inplace

.PHONY: test
test: build
	".venvs/${VENV}/bin/python" -m unittest lazyimp.tests.test_lazyimp

.PHONY: package
package: venv
	".venvs/${VENV}/bin/python" -m build .
