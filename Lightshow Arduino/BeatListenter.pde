// This class allows us to sample the audio stream to create the FFT
class BeatListener implements AudioListener
{
   private BeatDetect beat;
   private AudioPlayer source;
   
   BeatListener (BeatDetect beat, AudioPlayer source)
   {
     this.source = source;
     this.source.addListener(this);
     this.beat = beat;
   }
   
   void samples(float[] samps)
   {
     beat.detect(source.mix);
   }
   
   void samples(float[] sampsL, float[] sampsR)
   {
     beat.detect(source.mix);
   }
}
