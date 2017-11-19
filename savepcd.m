%SAVEPCD Write a point cloud to file in PCD format
%
% SAVEPCD(FNAME, P) writes the point cloud P to the file FNAME as an
% as a PCD format file.
%
% SAVEPCD(FNAME, P, 'binary') as above but save in binary format.  Default
% is ascii format.
%
% If P is a 2-dimensional matrix (MxN) then the columns of P represent the
% 3D points and an unorganized point cloud is generated.
%
%    If M=3 then the rows of P are x, y, z.
%    If M=6 then the rows of P are x, y, z, R, G, B where R,G,B are in the 
%      range 0 to 1.
%    If M=7 then the rows of P are x, y, z, R, G, B, A where R,G,B,A are in 
%      the range 0 to 1.
%
% If P is a 3-dimensional matrix (HxWxM) then an organized point cloud is 
% generated.
%
%    If M=3 then the planes of P are x, y, z.
%    If M=6 then the planes of P are x, y, z, R, G, B where R,G,B are in the 
%      range 0 to 1.
%    If M=7 then the planes of P are x, y, z, R, G, B, A where R,G,B,A are in 
%      the range 0 to 1.
%
% Notes::
% - Only the "x y z", "x y z rgb" and "x y z rgba" field formats are currently 
%   supported.
% - Cannot write binary_compressed format files
% See also pclviewer, lspcd, loaddpcd.
%
% Copyright (C) 2013, by Peter I. Corke

% TODO
% - option for binary write

function savepcd(fname, points, binmode)
    % save points in xyz format
    % TODO
    %  binary format, RGB
    
    ascii = true;
    if nargin < 3
        ascii = true;
    else
        switch binmode
            case 'binary'
                ascii = false;
            case 'ascii'
                ascii = true;
            otherwise
                error('specify ascii or binary');
        end
    end
    
    
    fp = fopen(fname, 'w');
    
    % find the attributes of the point cloud
    if ndims(points) == 2
        % unorganized point cloud
        npoints = size(points, 2);
        width = npoints;
        height  = 1;
        nfields = size(points, 1);
    else
        width = size(points, 2);
        height  = size(points, 1);
        npoints = width*height;
        nfields = size(points, 3);

        % put the data in order with one column per point
        points = permute(points, [2 1 3]);
        points = reshape(points, [], size(points,3))';
    end
    
    switch nfields
        case 3
            fields = 'x y z';
            count = '1 1 1';
            typ = 'F F F';
            siz = '4 4 4';
        case 6
            fields = 'x y z rgb';
            count = '1 1 1 1';
            if ascii
                typ = 'F F F F';
            else
                typ = 'F F F F';
            end
            siz = '4 4 4 4';
        case 7
            fields = 'x y z rgba';
            fields = 'x y z rgb';
            count = '1 1 1 1';
            if ascii
                typ = 'F F F I';
            else
                typ = 'F F F F';
            end
            siz = '4 4 4 4';
    end
    
    % write the PCD file header
    
    fprintf(fp, '# .PCD v.7 - Point Cloud Data file format\r\n');
    fprintf(fp, 'VERSION .7\r\n');
    
    fprintf(fp, 'FIELDS %s\r\n', fields);
    
    fprintf(fp, 'SIZE %s\r\n', siz);
    fprintf(fp, 'TYPE %s\r\n', typ);
    fprintf(fp, 'COUNT %s\r\n', count);
        
    fprintf(fp, 'WIDTH %d\r\n', width);
    fprintf(fp, 'HEIGHT %d\r\n', height);
    fprintf(fp, 'POINTS %d\r\n', npoints);
    
    
    
    switch nfields
        case 3

            
        case 6
            % RGB data
            RGB = uint32(points(4:6,:)*255);
            
            rgb = bitor(bitshift(RGB(1,:),16),bitshift(RGB(2,:),8));
            rgb = bitor(rgb,RGB(3,:));
            aaa = typecast(rgb, 'single');
            points = [ points(1:3,:); aaa];

            
        case 7
            % RGBA data
            RGBA = uint32(points(4:7,:)*255);
            
            rgba = ((RGBA(1,:)*256+RGBA(2,:))*256+RGBA(3,:))*256+RGBA(4,:);
            
            points = [ points(1:3,:); double(rgba)];
    end
    
    if ascii
        % Write ASCII format data
        fprintf(fp, 'DATA ascii\r\n');
        
        if nfields == 3
            % uncolored points
            fprintf(fp, '%f %f %f \r\n', points);
        else
            % colored points
            
            fprintf(fp, '%f %f %f %d \r\n', points);
        end
        
    else
        % Write binary format data
        fprintf(fp, 'DATA binary\r\n');
        
        % for a full color point cloud the colors are not quite right in pclviewer,
        % color as a float has only 23 bits of mantissa precision, not enough for
        % RGB as 8 bits each
        
        % write color as a float not an int
        fwrite(fp, points, 'float32');
    end

    fclose(fp);
end


    
function savepcd(fname, points, binmode)
    % save points in xyz format
    % TODO
    %  binary format, RGB
    
    ascii = true;
    if nargin < 3
        ascii = true;
    else
        switch binmode
            case 'binary'
                ascii = false;
            case 'ascii'
                ascii = true;
            otherwise
                error('specify ascii or binary');
        end
    end
    
    
    fp = fopen(fname, 'w');
    
    % find the attributes of the point cloud
    if ndims(points) == 2
        % unorganized point cloud
        npoints = size(points, 2);
        width = npoints;
        height  = 1;
        nfields = size(points, 1);
    else
        width = size(points, 2);
        height  = size(points, 1);
        npoints = width*height;
        nfields = size(points, 3);

        % put the data in order with one column per point
        points = permute(points, [2 1 3]);
        points = reshape(points, [], size(points,3))';
    end
    
    switch nfields
        case 3
            fields = 'x y z';
            count = '1 1 1';
            typ = 'F F F';
            siz = '4 4 4';
        case 6
            fields = 'x y z rgb';
            count = '1 1 1 1';
            if ascii
                typ = 'F F F F';
            else
                typ = 'F F F F';
            end
            siz = '4 4 4 4';
        case 7
            fields = 'x y z rgba';
            fields = 'x y z rgb';
            count = '1 1 1 1';
            if ascii
                typ = 'F F F I';
            else
                typ = 'F F F F';
            end
            siz = '4 4 4 4';
    end
    
    % write the PCD file header
    
    fprintf(fp, '# .PCD v.7 - Point Cloud Data file format\r\n');
    fprintf(fp, 'VERSION .7\r\n');
    
    fprintf(fp, 'FIELDS %s\r\n', fields);
    
    fprintf(fp, 'SIZE %s\r\n', siz);
    fprintf(fp, 'TYPE %s\r\n', typ);
    fprintf(fp, 'COUNT %s\r\n', count);
        
    fprintf(fp, 'WIDTH %d\r\n', width);
    fprintf(fp, 'HEIGHT %d\r\n', height);
    fprintf(fp, 'POINTS %d\r\n', npoints);
    
    
    
    switch nfields
        case 3

            
        case 6
            % RGB data
            RGB = uint32(points(4:6,:)*255);
            
            rgb = bitor(bitshift(RGB(1,:),16),bitshift(RGB(2,:),8));
            rgb = bitor(rgb,RGB(3,:));
            aaa = typecast(rgb, 'single');
            points = [ points(1:3,:); aaa];

            
        case 7
            % RGBA data
            RGBA = uint32(points(4:7,:)*255);
            
            rgba = ((RGBA(1,:)*256+RGBA(2,:))*256+RGBA(3,:))*256+RGBA(4,:);
            
            points = [ points(1:3,:); double(rgba)];
    end
    
    if ascii
        % Write ASCII format data
        fprintf(fp, 'DATA ascii\r\n');
        
        if nfields == 3
            % uncolored points
            fprintf(fp, '%f %f %f \r\n', points);
        else
            % colored points
            
            fprintf(fp, '%f %f %f %d \r\n', points);
        end
        
    else
        % Write binary format data
        fprintf(fp, 'DATA binary\r\n');
        
        % for a full color point cloud the colors are not quite right in pclviewer,
        % color as a float has only 23 bits of mantissa precision, not enough for
        % RGB as 8 bits each
        
        % write color as a float not an int
        fwrite(fp, points, 'float32');
    end

    fclose(fp);
end
