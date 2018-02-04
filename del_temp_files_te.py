"""
original from CP:

https://supportcenter.checkpoint.com/supportcenter/portal?action=portlets.DCFileAction&eventSubmit_doGetdcdetails=&fileid=55790

"""


import os, time, datetime, sys, shutil

fwdir = os.environ['FWDIR']
logpath = fwdir + '/log/del_tmp_files.elg'

prevent_email_folderpath = fwdir + '/tmp/email_tmp'
prevent_email_past = time.time() - 30*60 # 30 minutes
prevent_email_prefix = 'emailtemp'
prevent_email_suffix = ''

detect_email_folderpath = fwdir + '/tmp'
detect_email_past = time.time() - 30*60 # 30 minutes
detect_email_prefix = ''
detect_email_suffix = '_mail_body'

tex_folderpath = '/tmp/scrub'
tex_past = time.time() - 30*60 # 30 minutes
tex_prefix = ''
tex_suffix = ''

dlp_folderpath = fwdir + '/tmp/dlp'
dlp_past = time.time() - 30*60 # 30 minutes
dlp_prefix = ''
dlp_suffix = ''

def run(folder_path, past, prefix, suffix):
    if not os.path.exists(folder_path):
        print '%s does not exists' % folder_path
        return
    folder_files = os.listdir(folder_path)
    #print 'total number of files in the folder: %d' % len(folder_files)
    for file in folder_files:
        filepath = os.path.join(folder_path, file)

        # if path exists and it 'starts with prefix'/'ends with suffix'/'has no prefix and no suffix' then we should delete it 
        if (os.path.exists(filepath) and ((file.startswith(prefix) and prefix != '') or (file.endswith(suffix) and suffix != '') or (prefix == '' and suffix == '')) ):
            #print 'file to handle: %s' % file
            timestamp = os.path.getmtime(filepath)
            if timestamp < past:
                if os.path.isfile(filepath):
                    #print 'about to delete the file: %s' % filepath
                    os.remove(filepath)
                if os.path.isdir(filepath):
                    #print 'about to delete the folder: %s' % filepath
                    shutil.rmtree(filepath)

if __name__ == '__main__':
    old_stdout = sys.stdout
    with open(logpath,"a") as log_file:
        sys.stdout = log_file
        print '%s - running del_tmp_files.py (might take few minutes)...' % str(datetime.datetime.now()).split('.')[0]
        run(prevent_email_folderpath, prevent_email_past, prevent_email_prefix, prevent_email_suffix)
        run(detect_email_folderpath, detect_email_past, detect_email_prefix, detect_email_suffix)
        run(tex_folderpath, tex_past, tex_prefix, tex_suffix)
        run(dlp_folderpath, dlp_past, dlp_prefix, dlp_suffix)
        print '%s - all temporary files were deleted succesfully!' % str(datetime.datetime.now()).split('.')[0]
        sys.stdout = old_stdout
