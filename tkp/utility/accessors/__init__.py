#
# LOFAR Transients Key Project
#

# NOTE: use of numpy.squeeze() appears a bad idea, in the case of
# (unlikely, but not impossible) [1, Y] or [X, 1] shaped images...

"""
Data accessors.

These can be used to populate ImageData objects based on some data source
(FITS file, array in memory... etc).
"""

import pyfits
from tkp.database import Image as DBImage
from tkp.sourcefinder.image import ImageData

from tkp.utility.accessors.casaimage import *
from tkp.utility.accessors.fitsimage import *
from tkp.utility.accessors.dataaccessor import *


def dbimage_from_accessor(dataset, image):
    """Create an entry in the database images table from an image 'accessor'

    Args:

        - dataset (dataset.DataSet): DataSet for the image. Also
          provides the database connection.

        - image (DataAccessor): FITS/AIPS/HDF5 image available through
          an accessor

    Returns:

        (dataset.Image): a dataset.Image instance.
    """
    #if image.freqeff == 0 or image.freqeff is None or image.freqbw is None:
    if image.freqeff is None or image.freqbw is None:
        raise ValueError("cannot create database image: frequency information missing")
    data = {'tau_time': image.inttime,
            'freq_eff': image.freqeff,
            'freq_bw': image.freqbw,
            'taustart_ts': image.obstime.strftime("%Y-%m-%d %H:%M:%S.%f"),
            'url': image.filename,
            'band': 0,    # not yet clearly defined
            'bsmaj': float(image.beam[0]), ## NB We must cast to a standard python float
            'bsmin': float(image.beam[1]), ## as Monetdb converter cannot handle numpy.float64
            'bpa': float(image.beam[2]),
            }
    image = DBImage(data=data, dataset=dataset)
    return image


def sourcefinder_image_from_accessor(image):
    """Create a source finder ImageData object from an image 'accessor'

    Args:

        - image (DataAccessor): FITS/AIPS/HDF5 image available through
          an accessor.

    Returns:

        (sourcefinder.ImageData): a source finder image.
    """
    image = ImageData(image.data, image.beam, image.wcs)
    return image


def writefits(data, filename, header = {}):
    """
    Dump a NumPy array to a FITS file.

    Key/value pairs for the FITS header can be supplied in the optional
    header argument as a dictionary.
    """
    if header.__class__.__name__=='Header':
        pyfits.writeto(filename,data.transpose(),header)
    else:
        hdu = pyfits.PrimaryHDU(data.transpose())
        for key in header.iterkeys():
            hdu.header.update(key, header[key])
        hdu.writeto(filename)