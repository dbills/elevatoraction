#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <assert.h>

struct EXE_HEADER {
  unsigned short header;
  unsigned short start;
  unsigned short end;
} header;


/*
  create an atari dos executable header
  this code depends on the host being
  little endian like the 6502
 */
int main(int argc,char **argv) {
  assert(sizeof(header)==6);
  if(argc<2) {
    fprintf(stderr,"usage: %s <filename>\n",argv[0]);
    exit(1);
  }
  FILE *f = fopen(argv[1],"r+b");
  if(f) {
    fread(&header,sizeof(header),1,f);
    printf("start=%x end=%d\n",header.start,header.end);
    struct stat statbuf;
    if(stat(argv[1],&statbuf)!=0) {
      fprintf(stderr,"stat: %d",errno);
      exit(1);
    }
    header.end = header.start + statbuf.st_size - sizeof(header);
    fseek(f,0,SEEK_SET);
    fwrite(&header,sizeof(header),1,f);
    // append a segment that causes it to 'run'
    fseek(f,0,SEEK_END);

    /*
    // save the start address from original header
    unsigned short initaddr = header.start;

    header.start=0x02e2;
    header.end=0x02e3;
    fwrite(&header,sizeof(header),1,f);
    fwrite(&initaddr,sizeof(unsigned short),1,f);
    */
    fclose(f);
  } else {
    fprintf(stderr,"%s: bad file %s\n",argv[0],argv[1]);
  }
}
