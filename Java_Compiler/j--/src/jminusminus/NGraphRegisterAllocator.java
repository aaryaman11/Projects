// Copyright 2012- Bill Campbell, Swami Iyer and Bahar Akbal-Delibas

package jminusminus;
import java.util.*;

import static jminusminus.NPhysicalRegister.*;

/**
 * Implements register allocation using graph coloring algorithm.
 */
public class NGraphRegisterAllocator extends NRegisterAllocator {
    private int deg;
    private boolean[][] adjMatrix;
    private Graph<Integer> grap;
    private Stack<NInterval> color;
    private ArrayList<ArrayList<NInterval>> arrList;


    public class Graph<A> {
       final private HashMap<A, Set<A>> adjlist;

    public Graph() {
        this.adjlist = new HashMap<>();
    }
    // checking if vertex is there
    public boolean contains(A con) {
        return this.adjlist.containsKey(con);
    }
    // adding vertex to the graph
    public void verA(A v){
        this.adjlist.put(v, new HashSet<A>());
    }
    // removing vertex from the graph
    public void verR(A v){
        this.adjlist.remove(v);
    }
    // adding the edges to the graph
    public void add_edg(A source, A destination) {
        this.adjlist.get(source).add(destination);
        this.adjlist.get(destination).add(source);
    }
    // removing edges from the graph
    public void rem_edg(A source, A destination) {
        this.adjlist.get(source).remove(destination);
        this.adjlist.get(destination).remove(source);
    }



    }


//
//        // graph interference
////        LinkedList<Integer>[] adj_lst = new LinkedList<Integer>[];
////            for (int i = 32; i < cfg.intervals.size() - 1; i++) {
////                adj_lst[i] = new LinkedList<>();
////                for (int j = i + 1; j < cfg.intervals.size(); j++) {
////
////                }
////            }
//        public Graph(int n) {
//        }
//    }
//
//}


    /**
     * Constructs an NGraphRegisterAllocator object.
     *
     * @param cfg an instance of a control flow graph.
     */
    public NGraphRegisterAllocator(NControlFlowGraph cfg) {
        super(cfg);
        int deg = NPhysicalRegister.MAX_COUNT; // count of physical register
        int numRegi = cfg.intervals.size(); // initalizing for matrix size
        adjMatrix = new boolean[numRegi][numRegi];
        arrList = new ArrayList<ArrayList<NInterval>>();
        grap = new Graph();
        pruneGraph(arrList);
    }

    /**
     * {@inheritDoc}
     */
    public void allocation() {
        buildIntervals();
        buildInterferenceGraph();
        Queue<NInterval> assigned = new LinkedList<NInterval>();
        for (int i = 32, j = 0; i < cfg.intervals.size(); i++) {
            NInterval interval = cfg.intervals.get(i);
        }

        // checking if the interval overlapping and if they
//        for(int i = 0; i < (interval -1); i++) {
//
//        }






//            if (interval.pRegister == null) {
//                if (j >= MAX_COUNT) {
//                    // Pull out (from a queue) a register that's already assigned to another
//                    // interval and re-assign it to this interval. But then we have a spill
//                    // situation, so create an offset for the spill.
//                    NInterval spilled = assigned.remove();
//                    spilled.spill = true;
//                    if (spilled.offset == -1) {
//                        spilled.offset = cfg.offset++;
//                        spilled.offsetFrom = OffsetFrom.SP;
//                    }
//                    interval.pRegister = spilled.pRegister;
//                    interval.spill = true;
//                    if (interval.offset == -1) {
//                        interval.offset = cfg.offset++;
//                        interval.offsetFrom = OffsetFrom.SP;
//                    }
//                } else {
//                    // Allocate free register to interval.
//                    NPhysicalRegister pRegister = regInfo[T0 + j++];
//                    interval.pRegister = pRegister;
//                    cfg.pRegisters.add(pRegister);
//                }
//                assigned.add(interval);
//            }
//        }


    }
    // checking if the node is adjacent to each other
    // checking if one node is connected one another
    private void  buildInterferenceGraph() {
        for (int i = 32; i < cfg.intervals.size(); i++) {
            for (int j = i + 1; j < cfg.intervals.size(); j++) {
                adjMatrix[i][j] = isCollision(cfg.intervals.get(i), cfg.intervals.get(j));
                adjMatrix[j][i] = isCollision(cfg.intervals.get(i), cfg.intervals.get(j));
                // if this particular vertex it's not in the graph add it
                if (!grap.contains(i)) {
                    grap.verA(i);
                }

            }
        }
    }

    private void pruneGraph(ArrayList<ArrayList<NInterval>> ){
        while(color.size() < cfg.intervals.size() - 32){
            for(int i = 0; i < deg; i++){
//                for(int j = 0; j < temp.size(); j++){
//                    ArrayList<NInterval> current = temp.get(j);
//                    NInterval cur = cfg.intervals.get(j + 32);
                    if(current.size() == i && !color.contains(cur)){
                        color.push(cur);
                        for(ArrayList<NInterval> list : temp)
                            list.remove(cur);
                    }
                }
            }
        }
 // using the collision method to check the intervals
    private boolean isCollision(NInterval a, NInterval b){
        if (!(a.equals(b))) {
            for (NRange range : b.ranges) {
                if (a.isLiveAt(range.start)) {
                    return true;
                }
            }
        }
        return false;
    }

}
