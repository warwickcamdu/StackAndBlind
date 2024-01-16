#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "Folder name for randomly numbered images", style = "String") newImages

//Close any open images
close("*");

//Get the file names from the input directory
allFileNames = getFileList(input);

//Get the number of files.
//NB - Ensure no file names have spaces in them
numFiles = allFileNames.length;

//Open each file, Max Z project and rename.
for (i = 0; i < numFiles; i++)
{
	stringForOpening = "open=" + input + "/" + allFileNames[i] + " autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
	run("Bio-Formats Importer", stringForOpening);
	
	selectWindow(allFileNames[i]);
	numSlices = nSlices;
	
	if (numSlices > 1)
	{
		run("Z Project...", "projection=[Max Intensity]");
		newName = allFileNames[i] + "_stacked";
		rename(newName);
		close(allFileNames[i]);
	}
	
	//If the image is not a Z stack,
	//just rename it with _stacked anyway
	else
	{
		newName = allFileNames[i] + "_stacked";
		rename(newName);
	}
}

//Randomly shuffle the array to get random ID order
shuffle(allFileNames);

//Create csv with pairings
pairingsTableName = output + "/pairings.csv";
pairingsTable = File.open(pairingsTableName);
print(pairingsTable, "Image_Number,Original_File_Name \n");

for (i = 0; i < numFiles; i++)
{
	imageNumber = i + 1;
	print(pairingsTable, imageNumber + "," + allFileNames[i] + " \n");
}

File.close(pairingsTable);

//Make new directory for renamed images
newImageDirectory = output + File.separator + newImages;
File.makeDirectory(newImageDirectory);

//Rename and save files according to their new random numbers
//Images are also flattened in this step before saving
for (i = 0; i < numFiles; i++)
{
	imageNumber = i + 1;
	currentName = allFileNames[i] + "_stacked";
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