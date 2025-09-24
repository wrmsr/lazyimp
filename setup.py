import setuptools as st


st.setup(
    ext_modules=[
        st.Extension(
            name='lazyimp._capture',
            sources=['lazyimp/_capture.cc'],
            extra_compile_args=['-std=c++20'],
            optional=True,
        ),
    ],
)
