

static 		ViUInt32 		write_count;
static 		ViUInt32 		read_count;
static		char			  tos = '\0';
static		char*			  chr = &tos;



//                    //
//    advanced IOs    // 
//                    //
DLL int parse_header            //this functions parse the header of curve? which
  (visa_session *se)            //is of the form <header>#a<bbb><data> where a is 
{                               //the number of b and bbb is the number of data
	for(;;)
		if (scan_next(se) == '#') 
			break;
	int i = scan_next(se) - '0';
	int j = 0,t = 0;
	for (j = 0; j < i; j++)
		t = 10*t+(scan_next(se)- '0');
	Prompt("data is: %i\n",t);
	return t;
}

DLL int read_n_do
  (visa_session *se, int frm_siz)
{
  if (se->callback == NULL) {
    Prompt("no callback set for %s", se->address);
    return -1;
  }
	int dat_siz = parse_header(se);
	int num_frm = dat_siz/frm_siz;
	int contains = (se->buf_siz) / frm_siz;
	int j, total = 0;
	int frm_read =0;
	for (; frm_read < num_frm; frm_read += contains) {
		contains = num_frm-frm_read>contains ? contains : num_frm-frm_read;
		total += read(se, se->buffer, frm_siz*contains);   //read in buffer an exact number of 
                                                 //frame data without overflowing the buffer
		for(j = 0; j< contains; j++)
			se->callback(se->buffer + j*frm_siz, frm_siz);
	}
	scan_next(se);                                 //check end of line
	return total;
}

