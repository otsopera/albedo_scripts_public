function idxs = m_n_grid_coordinates_to_lin_row_idx(m,n,m_coors,n_coors)

tot_N = m*n;

running_numbering = 1:tot_N;

gridded_numbering = reshape(running_numbering,n,m)';

idxs = gridded_numbering(m_coors,n_coors);
idxs = sort(idxs(:));