import setuptools as st


st.setup(
    ext_modules=[
        st.Extension(
            name='lazyimp._capture',
            sources=['lazyimp/_capture.c'],
            extra_compile_args=['-std=c11'],
            optional=True,
        ),
    ],
)
