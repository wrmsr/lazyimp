import functools  # noqa
import sys
import threading
import time

from ... import capture  # noqa
from ... import proxy  # noqa


def _main() -> None:
    say_lock = threading.Lock()

    st_ns = time.time_ns()

    def say(s):
        with say_lock:
            print(
                f'thr:{threading.current_thread().name} '
                f'tid:{threading.get_native_id():x} '
                f'ns:{time.time_ns() - st_ns:_} '
                f'{s}',
                file=sys.stderr,
            )

    #

    ev = [threading.Event() for _ in range(3)]

    def a_main():
        ev[0].set()
        ev[2].wait()

        say('start')
        from .base import moda  # noqa
        say('end')

    def b_main():
        ev[1].set()
        ev[2].wait()

        say('start')
        from .base import modb  # noqa
        say('end')

    a_thr = threading.Thread(name='a', target=a_main)
    b_thr = threading.Thread(name='b', target=b_main)

    a_thr.start()
    b_thr.start()
    ev[0].wait()
    ev[1].wait()
    ev[2].set()
    a_thr.join()
    b_thr.join()


if __name__ == '__main__':
    _main()
