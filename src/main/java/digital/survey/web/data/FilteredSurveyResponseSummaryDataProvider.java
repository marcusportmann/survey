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
import digital.survey.model.SurveyResponseSummary;
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
 * The <code>FilteredSurveyResponseDataProvider</code> class provides an <code>IDataProvider</code>
 * implementation that retrieves <code>SurveyResponse</code> instances from the database.
 *
 * @author Marcus Portmann
 */
public class FilteredSurveyResponseSummaryDataProvider
    extends InjectableDataProvider<SurveyResponseSummary>
{
  private static final long serialVersionUID = 1000000;

  /**
   * The filter used to limit the matching survey responses.
   */
  private String filter = "";

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to identify the survey instance the survey
   * responses are associated with.
   */
  private UUID surveyInstanceId;

  /**
   * Constructs a new <code>FilteredSurveyResponseDataProvider</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected FilteredSurveyResponseSummaryDataProvider() {}

  /**
   * Constructs a new <code>FilteredSurveyResponseDataProvider</code>.
   *
   * @param surveyInstanceId the Universally Unique Identifier (UUID) used to identify the survey
   *                         instance the survey responses are associated with
   */
  public FilteredSurveyResponseSummaryDataProvider(UUID surveyInstanceId)
  {
    this.surveyInstanceId = surveyInstanceId;
  }

  /**
   * @see org.apache.wicket.model.IDetachable#detach()
   */
  public void detach() {}

  /**
   * Returns the filter used to limit the matching survey responses.
   *
   * @return the filter used to limit the matching survey responses
   */
  @SuppressWarnings("unused")
  public String getFilter()
  {
    return filter;
  }

  /**
   * Retrieves the matching survey responses from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>.
   *
   * @param first the index of the first entry to return
   * @param count the number of the entries to return
   *
   * @return the survey responses retrieved from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#iterator(long, long)
   */
  public Iterator<SurveyResponseSummary> iterator(long first, long count)
  {
    try
    {
      List<SurveyResponseSummary> allSurveyResponses = StringUtil.isNullOrEmpty(filter)
          ? surveyService.getSurveyResponseSummariesForSurveyInstance(surveyInstanceId)
          : surveyService.getFilteredSurveyResponseSummariesForSurveyInstance(surveyInstanceId,
              filter);

      return allSurveyResponses.subList((int) first, (int) Math.min(first + count,
          allSurveyResponses.size())).iterator();
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the summaries for the survey responses for the survey instance (%s)"
          + " matching the filter (%s) from index (%d) to (%d)", surveyInstanceId, filter, first,
          first + count - 1), e);
    }
  }

  /**
   * Wraps the retrieved <code>SurveyResponseSummary</code> POJO with a Wicket model.
   *
   * @param surveyResponseSummary the <code>SurveyResponseSummary</code> instance to wrap
   *
   * @return the Wicket model wrapping the <code>SurveyResponse</code> instance
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#model(java.lang.Object)
   */
  public IModel<SurveyResponseSummary> model(SurveyResponseSummary surveyResponseSummary)
  {
    return new DetachableSurveyResponseSummaryModel(surveyResponseSummary);
  }

  /**
   * Set the filter used to limit the matching survey responses.
   *
   * @param filter the filter used to limit the matching survey responses
   */
  public void setFilter(String filter)
  {
    this.filter = filter;
  }

  /**
   * Returns the total number of survey responses.
   *
   * @return the total number of survey responses
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#size()
   */
  public long size()
  {
    try
    {
      return StringUtil.isNullOrEmpty(filter)
          ? surveyService.getNumberOfSurveyResponsesForSurveyInstance(surveyInstanceId)
          : surveyService.getNumberOfFilteredSurveyResponsesForSurveyInstance(surveyInstanceId,
              filter);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(
          "Failed to retrieve the number of survey responses for the survey instance ("
          + surveyInstanceId + ") matching the filter (" + filter + ")", e);
    }
  }
}
