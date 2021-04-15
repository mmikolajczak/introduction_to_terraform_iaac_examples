import logging
import os
import sys


def _get_logger(min_level: str) -> logging.Logger:

    class StandardHandlerFilter(logging.Filter):
        def filter(self, record: logging.LogRecord):
            return record.levelno < logging.WARNING

    formatter = logging.Formatter('[%(levelname)s] %(message)s')
    error_stream_handler = logging.StreamHandler(stream=sys.stderr)
    error_stream_handler.setFormatter(formatter)
    error_stream_handler.setLevel(logging.WARNING)

    stdout_stream_handler = logging.StreamHandler(stream=sys.stdout)
    stdout_stream_handler.setFormatter(formatter)
    stdout_stream_handler.addFilter(StandardHandlerFilter())

    logger = logging.getLogger('kl_volumetric_meshing_stage')
    logger.addHandler(error_stream_handler)
    logger.addHandler(stdout_stream_handler)
    logger.setLevel(getattr(logging, min_level.upper()))

    return logger


log = _get_logger(os.getenv('LOG_LEVEL', 'DEBUG'))
