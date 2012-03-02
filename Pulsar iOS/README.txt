Setup instructions:
1. Add the Pulsar Project as a project reference to your own
2. Add Pulsar in "Target Dependencies" in your Target's Build Phases tab
3. Add libPulsarKit, AudioToolbox, Accelerate, QuartzCore and Core Data in "Link Binary With Libraries" in your Target's Build Phases tab
4. Add RoutableSynth's relative path (e.g. "../ThirdParty/RoutableSynth") to your Project's "Header Search Paths" in the "Build Settings" tab
5. Add "-ObjC" to your Project's "Other Linker Flags" in the "Build Settings" tab
6. Drag the 'Pulsar Bundle' from the RoutableSynth project into your project
7. Add [Pulsar sharedPulsar] to applicationDidFinishLaunching in your App Delegate to initialize RoutableSynthKit and boot the synthesis server
8. Call [[Pulsar sharedPulsar] graphNamed:<graphName>] to request graphs
9. Your app delegate must be .mm







*ADVANCED NOTES FOR USE WITH AN EXTERNAL SUPERCOLLIDER INSTANCE
It is a good idea to set the following ServerOptions in your startup.rtf/startup.scd:
Server.local.options.numAudioBusChannels = 4096;
Server.local.options.maxNodes = 16384;

as RoutableSynth uses more audio buses and nodes than the average SC program.

You also must copy all .scsyndef synthdef files in RoutableSynths bundle to your local ~/Library/Application Support/SuperCollider/synthdefs directory, or run RoutableSynth's SuperCollider script.
