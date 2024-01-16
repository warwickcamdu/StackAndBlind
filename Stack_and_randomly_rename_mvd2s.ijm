//Cannot have space in input file name
#@ File (label = "Input mvd2 file", style = "open") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "Folder name for randomly numbered images", style = "String") newImages

//Close any open images
close("*");

//Open the MVD2 - all series
stringForOpening = "open=" + input + " autoscale open_all_series color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";

run("Bio-Formats Importer", stringForOpening);

//Get number of images now opened
numImages = nImages();

//Get the names of the opened images
allImageNames = getList("image.titles");

//Select each image, Max Z project and rename.
for (i = 0; i < numImages; i++)
{
	selectWindow(allImageNames[i]);
	numSlices = nSlices;
	
	if (numSlices > 1)
	{
		run("Z Project...", "projection=[Max Intensity]");
		newName = allImageNames[i] + "_stacked";
		rename(newName);
		close(allImageNames[i]);
	}
	
	//If the image is not a Z stack,
	//just rename it with _stacked anyway
	else
	{
		newName = allImageNames[i] + "_stacked";
		rename(newName);
	}
}

//Randomly shuffle the array to get random ID order
shuffle(allImageNames);

//Create csv with pairings
pairingsTableName = output + "/pairings.csv";
pairingsTable = File.open(pairingsTableName);
print(pairingsTable, "Image_Number,Original_Image_Name \n");

for (i = 0; i < numImages; i++)
{
	imageNumber = i + 1;
	print(pairingsTable, imageNumber + "," + allImageNames[i] + " \n");
}

File.close(pairingsTable);

//Make new directory for renamed images
newImageDirectory = output + File.separator + newImages;
File.makeDirectory(newImageDirectory);

//Rename and save files according to their new random numbers
//Images are also flattened in this step before saving
for (i = 0; i < numImages; i++)
{
	imageNumber = i + 1;
	currentName = allImageNames[i] + "_stacked";
	newSaveName = newImageDirectory + File.separator + "Image_" + imageNumber;
	selectWindow(currentName);
	run("Flatten", "stack");
	saveAs("Tiff", newSaveName);
	close();
	close(currentName);
}

//Fisher Yates shuffling algorithm
//from https://imagej.nih.gov/ij/macros/examples/RandomizeArray.txt

function shuffle(array) {
   n = array.length;  // The number of items left to shuffle (loop invariant).
   while (n > 1) {
      k = randomInt(n);     // 0 <= k < n.
      n--;                  // n is now the last pertinent index;
      temp = array[n];  // swap array[n] with array[k] (does nothing if k==n).
      array[n] = array[k];
      array[k] = temp;
   }
}

// returns a random number, 0 <= k < n
function randomInt(n) {
   return n * random();
}