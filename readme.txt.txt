VOIGUIv2

Copyright (c) 2018, NICK CALVERT

A MATLAB tool for using Stereolitohrapy (.stl) files to generate Regions/Volumes of Interest (ROIs/VOIs) on SPECT/CT images and use these to calculate calibration factors.

This tool has been written and tested using SPECT/CT files obtained using the GE Discovery 670 SPECT/CT scanner located at the Christie NHS Foundation Trust.
Images from other scanners may work but are not supported.

The application is ran with no inputs, upon execution the user will be asked to locate the CT files to import.
Once the CT images have been imported, the user will then be asked to import the SPECT file and subsequently the .stl files.
The triangular meshes can be translated and rotated so that they line up with the CT by using the buttons at the bottom of the GUI. The CT image contrast can be altered using the top sliders.
The SPECT images are overlaid on top of the CT images to aid with alignment.

Once the meshes have been aligned, calibration factors can be calculated by using one of the buttons at the top-right of the GUI labelled 'Stock Fill' and 'Individual Fill'.

Stock Fill is used if the inserts were filled from a stock radioactive solution, Individual Fill is used if the inserts were filled with individual activityu concentrations.
Currently Lu-177, Y-90, I-131, and Tc-99m is supported.

The ROIs and the calibration factors can be saved using the appropriate buttons.

WARNING: The Optimise stl Positions tool is experimental and may not work very well. It is *NOT* suited for images where there is significant spill-in to the ROIs.


The application uses functions from the following MATLAB toolboxes that were downloaded from the MathWorks File Exchange:
dicm2nii Copyright (c) 2017, Xiangrui Li: https://uk.mathworks.com/matlabcentral/fileexchange/42997-xiangruili-dicm2nii
inpolyhedron Copyright (c) 2015, Sven
: https://uk.mathworks.com/matlabcentral/fileexchange/37856-inpolyhedron-are-points-inside-a-triangulated-volume-
Tools for NIfTI and ANALYZE image Copyright (c) 2014, Jimmy Shen: https://uk.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image
progressbar Copyright (c) 2005, Steve Hoelzer: https://uk.mathworks.com/matlabcentral/fileexchange/6922-progressbar
stlwrite Copyright (c) 2018, Sven Holcomb: https://uk.mathworks.com/matlabcentral/fileexchange/20922-stlwrite-write-ascii-or-binary-stl-files






THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
