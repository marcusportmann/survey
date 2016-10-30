/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyInstance;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableDataProvider;
import guru.mmp.common.util.StringUtil;
import org.apache.wicket.model.IModel;

import javax.inject.Inject;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>FilteredSurveyInstanceDataProvider</code> class provides an <code>IDataProvider</code>
 * implementation that retrieves <code>SurveyInstance</code> instances from the database.
 *
 * @author Marcus Portmann
 */
public class FilteredSurveyInstanceDataProvider extends InjectableDataProvider<SurveyInstance>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to identify the survey definition the survey
   * instances are associated with.
   */
  private UUID surveyDefinitionId;

  /**
   * The filter used to limit the matching survey instances.
   */
  private String filter = "";

  /**
   * Constructs a new <code>FilteredSurveyInstanceDataProvider</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected FilteredSurveyInstanceDataProvider() {}

  /**
   * Constructs a new <code>FilteredSurveyInstanceDataProvider</code>.
   *
   * @param surveyDefinitionId the Universally Unique Identifier (UUID) used to identify the survey
   *                           definition the survey instances are associated with
   */
  public FilteredSurveyInstanceDataProvider(UUID surveyDefinitionId)
  {
    this.surveyDefinitionId = surveyDefinitionId;
  }

  /**
   * @see org.apache.wicket.model.IDetachable#detach()
   */
  public void detach() {}

  /**
   * Returns the filter used to limit the matching survey instances.
   *
   * @return the filter used to limit the matching survey instances
   */
  @SuppressWarnings("unused")
  public String getFilter()
  {
    return filter;
  }

  /**
   * Retrieves the matching survey instances from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>.
   *
   * @param first the index of the first entry to return
   * @param count the number of the entries to return
   *
   * @return the survey instances retrieved from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#iterator(long, long)
   */
  public Iterator<SurveyInstance> iterator(long first, long count)
  {
    try
    {
      List<SurveyInstance> allSurveyInstances = StringUtil.isNullOrEmpty(filter)
          ? surveyService.getSurveyInstancesForSurveyDefinition(surveyDefinitionId)
          : surveyService.getFilteredSurveyInstancesForSurveyDefinition(surveyDefinitionId, filter);

      return allSurveyInstances.subList((int) first, (int) Math.min(first + count,
          allSurveyInstances.size())).iterator();
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the survey instances for the survey definition (%s)"
          + " matching the filter (%s) from index (%d) to (%d)", surveyDefinitionId, filter, first,
          first + count - 1), e);
    }
  }

  /**
   * Wraps the retrieved <code>SurveyInstance</code> POJO with a Wicket model.
   *
   * @param surveyInstance the <code>SurveyInstance</code> instance to wrap
   *
   * @return the Wicket model wrapping the <code>SurveyInstance</code> instance
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#model(java.lang.Object)
   */
  public IModel<SurveyInstance> model(SurveyInstance surveyInstance)
  {
    return new DetachableSurveyInstanceModel(surveyInstance);
  }

  /**
   * Set the filter used to limit the matching survey instances.
   *
   * @param filter the filter used to limit the matching survey instances
   */
  public void setFilter(String filter)
  {
    this.filter = filter;
  }

  /**
   * Returns the total number of survey instances.
   *
   * @return the total number of survey instances
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#size()
   */
  public long size()
  {
    try
    {
      return StringUtil.isNullOrEmpty(filter)
          ? surveyService.getNumberOfSurveyInstancesForSurveyDefinition(surveyDefinitionId)
          : surveyService.getNumberOfFilteredSurveyInstancesForSurveyDefinition(surveyDefinitionId,
              filter);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(
          "Failed to retrieve the number of survey instances for the survey definition ("
          + surveyDefinitionId + ") matching the filter (" + filter + ")", e);
    }
  }
}
