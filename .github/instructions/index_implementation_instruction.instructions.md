Generate an XML file for a vegetation index using the following inputs:

[Full name of the index]
[Abbreviation, e.g., ARI1]
[Formula, e.g., (1/R550)-(1/R700)]
Requirements:

Lowercase the abbreviation and use it as the filename: inst/extdata/indices/[abbreviation_lowercase].xml.
The XML file must contain:
<Name>: The abbreviation.
<Wavelengths>: List all unique wavelengths used in the formula as <Band name="Rxxx" min="xxx" max="xxx" unit="nm"/>. There are also ranges like R400:R450, which should be represented as min="400" max="450" select="min-distance". BLUE is R420:R480, GREEN is R480:R570, RED is R640:R760, NIR is R780:R1400.
<MathML>: Serialize the formula in MathML format. Oncly constants and variables can be operands.
<Metadata>: <Description> tag with the index name and abbreviation.
Use the following XML structure:

<?xml version="1.0" encoding="UTF-8"?>
<SpectralIndex>
    <Name>[Abbreviation]</Name>
    <Wavelengths>
        <!-- Bands for each wavelength used in the formula -->
    </Wavelengths>
    <MathML>
        <!-- MathML serialization of the formula -->
    </MathML>
    <Metadata>
        <Description>[Index name] ([Abbreviation])</Description>
    </Metadata>
</SpectralIndex>

Example input:

Anthocyanin Reflectance Index 1
ARI1
(1/R550)-(1/R700)
Expected output:

<?xml version="1.0" encoding="UTF-8"?>
<SpectralIndex>
    <Name>ARI1</Name>
    <Wavelengths>
        <Band name="R550" min="550" max="550" unit="nm"/>
        <Band name="R700" min="700" max="700" unit="nm"/>
    </Wavelengths>
    <MathML>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
            <apply>
                <minus/>
                <apply>
                    <divide/>
                    <cn>1.0</cn>
                    <ci>R550</ci>
                </apply>
                <apply>
                    <divide/>
                    <cn>1.0</cn>
                    <ci>R700</ci>
                </apply>
            </apply>
        </math>
    </MathML>
    <Metadata>
        <Description>Anthocyanin Reflectance Index 1 (ARI1)</Description>
    </Metadata>
</SpectralIndex>

A file ari1.xml with the content as shown in the example above.